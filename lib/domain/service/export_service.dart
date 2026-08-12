import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/data/helper/export_key.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/data_export_model.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class ExportService {
  static final _filePath =
      '{prefix}/stack_money_backup/stack_money_{timestamp}.json';
  static final _prefix = '{prefix}';
  static final _timestamp = '{timestamp}';

  Future<DataExportModel?> createAppDataExport() async {
    try {
      final plans = AppCoordinator.instance.plans.value;
      final buckets = AppCoordinator.instance.buckets.value;
      final history = AppCoordinator.instance.history.value;

      final file = await _createExportFile(
        _convertDataToExport(
          jsonMap: _createJsonData(
            plans: plans,
            buckets: buckets,
            history: history,
          ),
        ),
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
      await _createExportFile(_convertDataToExport(jsonList: data)),
    );
  }

  Future<String> extractDataToAI() async {
    final history = AppCoordinator.instance.history.value.reversed.toList();

    final jsonMap = {
      ExportKey.currentPlan: AppCoordinator.instance.currentPlan.value
          ?.toJson(),
      ExportKey.latestHistory: history
          .getRange(0, 3)
          .map((h) => h.toJson())
          .toList(),
      ExportKey.buckets: AppCoordinator.instance.buckets.value
          .map((b) => b.toJson())
          .toList(),
    };

    return _convertDataToExport(jsonMap: jsonMap);
  }

  Future<ShareResult> shareFile(File file) async {
    final XFile xFile = XFile(file.path, mimeType: ExportKey.mimeType);

    return await SharePlus.instance.share(ShareParams(files: [xFile]));
  }

  String _convertDataToExport({
    Map<String, Object?>? jsonMap,
    List<Object?>? jsonList,
  }) {
    if (jsonMap == null && jsonList == null) {
      throw Exception('Must fill one of the two (jsonMap || jsonList');
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

  Future<File> _createExportFile(String jsonString) async {
    final Directory tempDir = await getTemporaryDirectory();
    final filePath = _filePath
        .replaceAll(_prefix, tempDir.path)
        .replaceAll(
          _timestamp,
          Timestamp.now().millisecondsSinceEpoch.toString(),
        );

    final file = await File(filePath).create(recursive: true);
    return await file.writeAsString(jsonString);
  }
}
