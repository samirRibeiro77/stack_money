import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/enum/export_parameters.dart';
import 'package:stack_money/data/helper/export_key.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/ai_context.dart';
import 'package:stack_money/data/models/ai_export_model.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/data_export_model.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class ExportService {
  final _remoteConfig = FirebaseRemoteConfig.instance;

  static const _fileName = 'stack_money';
  static const _defaultChat = 'personal_cfo';

  Future<DataExportModel?> createAppDataExport() async {
    try {
      final plans = AppCoordinator.instance.plans.value;
      final buckets = AppCoordinator.instance.buckets.value;
      final history = AppCoordinator.instance.history.value;

      final file = await _createExportFile(
        text: _convertDataToExport(
          jsonMap: _createJsonData(
            plans: plans,
            buckets: buckets,
            history: history,
          ),
        ),
        kind: ExportKind.backup,
      );

      return DataExportModel(
        planQty: plans.length,
        bucketQty: buckets.length,
        historyQty: history.length,
        file: file,
      );
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error retrieving data to share',
        scope: ExceptionScope.business,
        exception: e as Exception,
        stackTrace: stack,
      );
    }

    return null;
  }

  Future<ShareResult> exportData(List<Object?> data) async {
    return await shareFile(
      await _createExportFile(text: _convertDataToExport(jsonList: data)),
    );
  }

  Future<AiContext> extractDataToAI() async {
    final fbHistory = AppCoordinator.instance.history.value;
    fbHistory.sort((a, b) => b.date.compareTo(a.date));

    return AiContext(
      currentPlan: AppCoordinator.instance.currentPlan.value,
      buckets: AppCoordinator.instance.buckets.value,
      history: AppCoordinator.instance.history.value,
    );
  }

  Future<AiExportModel> exportToLLM({
    String? chatName,
    List<ChatMessageModel>? messages,
  }) async {
    final systemPrompt = _remoteConfig.getString(FirebaseKey.cfoSystemPrompt);

    return AiExportModel(
      systemPrompt: systemPrompt,
      plans: AppCoordinator.instance.plans.value,
      buckets: AppCoordinator.instance.buckets.value,
      history: AppCoordinator.instance.history.value,
      chatName: chatName != null
          ? StackMoneyString.formatTitle(chatName)
          : chatName,
      messages: messages,
    );
  }

  Future<ShareResult> shareFile(File file) async {
    final XFile xFile = XFile(file.path, mimeType: ExportKey.mimeType);

    return await SharePlus.instance.share(ShareParams(files: [xFile]));
  }

  Future<ShareResult> shareMarkdownFile(AiExportModel export) async {
    final file = await _createExportFile(
      name: export.chatName ?? _defaultChat,
      text: export.toMD(),
      kind: ExportKind.cfo,
      extension: ExportExtension.md,
      timestamp: false,
    );
    final XFile xFile = XFile(file.path, mimeType: 'text/markdown');

    return await SharePlus.instance.share(ShareParams(files: [xFile]));
  }

  String _convertDataToExport({
    Map<String, Object?>? jsonMap,
    List<Object?>? jsonList,
  }) {
    if (jsonMap == null && jsonList == null) {
      throw Exception('Must fill one of the two (jsonMap || jsonList)');
    }

    return jsonEncode(
      jsonMap ?? jsonList,
      toEncodable: (nonEncodable) {
        if (nonEncodable is Timestamp) {
          return nonEncodable.toDate().toIso8601String();
        }
        return nonEncodable.toString();
      },
    );
  }

  Map<String, Object?> _createJsonData({
    List<SalaryPlan> plans = const [],
    List<Bucket> buckets = const [],
    List<History> history = const [],
  }) {
    final jsonData = <String, Object?>{};

    if (plans.isNotEmpty) {
      jsonData[FirebaseKey.salaryPlans] = plans.map((p) => p.toJson()).toList();
    }

    if (buckets.isNotEmpty) {
      jsonData[FirebaseKey.buckets] = buckets.map((b) => b.toJson()).toList();
    }

    if (history.isNotEmpty) {
      jsonData[FirebaseKey.history] = history.map((h) => h.toJson()).toList();
    }

    return jsonData;
  }

  Future<String> _filePath({
    required ExportExtension extension,
    required ExportKind kind,
    required String name,
    required bool timestamp,
  }) async {
    final buffer = StringBuffer();
    final Directory tempDir = await getTemporaryDirectory();
    buffer.write('${tempDir.path}/stack_money_${kind.name}');
    buffer.write('/');
    buffer.write(name);
    buffer.write(
      timestamp ? '_${Timestamp.now().millisecondsSinceEpoch.toString()}' : '',
    );
    buffer.write('.${extension.name}');

    final filePath = buffer.toString();
    SmLogger.debug('Got file path', payload: {'path': filePath});
    return filePath;
  }

  Future<File> _createExportFile({
    required String text,
    String name = _fileName,
    ExportExtension extension = ExportExtension.json,
    ExportKind kind = ExportKind.data,
    bool timestamp = true,
  }) async {
    final filePath = await _filePath(
      name: name,
      extension: extension,
      kind: kind,
      timestamp: timestamp,
    );

    final file = await File(filePath).create(recursive: true);
    return await file.writeAsString(text);
  }
}
