import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/data_export_model.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';

class ExportService {
  static final _filePath =
      '{prefix}/stack_money/stack_money_p{p}_b{b}_h{h}_{timestamp}.json';
  static final _prefix = '{prefix}';
  static final _plans = '{p}';
  static final _buckets = '{b}';
  static final _history = '{h}';
  static final _timestamp = '{timestamp}';

  Future<DataExportModel?> prepareSharedJson() async {
    try {
      final results = await Future.wait([
        PlanManagementService().fetch(),
        BucketManagementService().fetch(),
        HistoryManagementService().fetch(),
      ]);

      final plans = results[0] as List<SalaryPlan>;
      final buckets = results[1] as List<Bucket>;
      final history = results[2] as List<History>;

      return await _createExportFile(plans, buckets, history);
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

  Future<DataExportModel> _createExportFile(
    List<SalaryPlan> plans,
    List<Bucket> buckets,
    List<History> history,
  ) async {
    final Map<String, Object?> jsonMap = {
      'plans': plans.map((p) => p.toJson()).toList(),
      'buckets': buckets.map((b) => b.toJson()).toList(),
      'history': history.map((h) => h.toJson()).toList(),
    };

    final String jsonString = jsonEncode(
      jsonMap,
      toEncodable: (nonEncodable) {
        if (nonEncodable is Timestamp) {
          return nonEncodable.toDate().toIso8601String();
        }
        return nonEncodable.toString();
      },
    );

    final Directory tempDir = await getTemporaryDirectory();
    final filePath = _filePath
        .replaceAll(_prefix, tempDir.path)
        .replaceAll(_plans, plans.length.toString())
        .replaceAll(_buckets, buckets.length.toString())
        .replaceAll(_history, history.length.toString())
        .replaceAll(
          _timestamp,
          Timestamp.now().millisecondsSinceEpoch.toString(),
        );

    final file = await File(filePath).create(recursive: true);
    final writtenFile = await file.writeAsString(jsonString);

    return DataExportModel(
      planQty: plans.length,
      bucketQty: buckets.length,
      historyQty: history.length,
      file: writtenFile,
    );
  }

  Future<ShareResult> shareExportFile(DataExportModel dataExport) async {
    final XFile xFile = XFile(
      dataExport.file!.path,
      mimeType: 'application/json',
    );

    return await SharePlus.instance.share(ShareParams(files: [xFile]));
  }
}
