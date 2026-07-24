import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/data_export_model.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';

class ExportService {
  static final _filePath =
      '{prefix}/stack_money_backup/stack_money_{timestamp}.json';
  static final _prefix = '{prefix}';
  static final _timestamp = '{timestamp}';

  Future<DataExportModel?> createAppDataExport() async {
    try {
      final results = await Future.wait([
        PlanManagementService().fetch(),
        BucketManagementService().fetch(),
        HistoryManagementService().fetch(),
      ]);

      final plans = results[0] as List<SalaryPlan>;
      final buckets = results[1] as List<Bucket>;
      final history = results[2] as List<History>;

      final file = await _createExportFile(
        _convertDataToString(
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
        payload: {'exception': e},
        stackTrace: stack,
      );
    }

    return null;
  }

  Future<ShareResult> shareExportFile(DataExportModel dataExport) async {
    final XFile xFile = XFile(
      dataExport.file!.path,
      mimeType: 'application/json',
    );

    return await SharePlus.instance.share(ShareParams(files: [xFile]));
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

  String _convertDataToString({
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
