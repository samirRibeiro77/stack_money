import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';

enum DataJsonClass { history, buckets, plans }

class DataPipelineManager {
  final _planService = PlanManagementService();
  final _bucketService = BucketManagementService();
  final _historyService = HistoryManagementService();

  Future<List<Object?>> _getFileData(DataJsonClass jsonClass) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/backup/stack_money_backup.json',
      );

      return json.decode(jsonString)[jsonClass.name];
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error loading JSON file',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );

      return [];
    }
  }

  Future<Map<String, String>> _getBucketIds() async {
    try {
      final buckets = await _bucketService.fetch();
      return Map.fromEntries(buckets.map((b) => MapEntry(b.name, b.id)));
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error fetching bucket ids',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );

      return {};
    }
  }

  Future<void> loadBuckets() async {
    SmLogger.debug('Init loading buckets to Firebase', payload: {});
    final firebaseData = await _bucketService.fetch();
    final localData = await _getFileData(DataJsonClass.buckets);
    int howManyCreated = 0;

    SmLogger.debug(
      'Preparing to upload buckets',
      payload: {'firebase': firebaseData.length, 'local': localData.length},
    );

    for (final bJson in localData) {
      final localBucket = Bucket.fromJson(bJson as Map<String, Object?>);
      final firebaseBucket = firebaseData
          .where((b) => b.name == localBucket.name)
          .firstOrNull;

      if (firebaseBucket == null) {
        final createBucket = localBucket.copyWith(newId: true);
        _bucketService.save(createBucket);
        howManyCreated++;
      }
    }

    SmLogger.debug(
      'Finished upload buckets',
      payload: {'created': howManyCreated},
    );
  }

  Future<void> loadHistory() async {
    SmLogger.debug('Init loading history to Firebase', payload: {});
    final firebaseData = await _historyService.fetch();
    final localData = await _getFileData(DataJsonClass.history);
    final bucketIds = await _getBucketIds();
    int howManyCreated = 0;

    for (final hJson in localData) {
      final localHistory = History.fromJson(hJson as Map<String, Object?>);
      final firebaseHistory = firebaseData
          .where((h) => h.date == localHistory.date)
          .firstOrNull;

      if (firebaseHistory == null) {
        final resolvedTransactions = <Transaction>[];

        for (final transaction in localHistory.transactions) {
          final name = '${transaction.where} ${transaction.category}';
          final bucketId = bucketIds[name];

          final newTransaction = Transaction.create(
            bucketId!,
            transaction.actualValue,
            category: transaction.category,
            where: transaction.where,
          );

          resolvedTransactions.add(newTransaction);
        }

        final createHistory = History.withValues(
          date: localHistory.date,
          immediateLiquidityTotal: localHistory.immediateLiquidityTotal,
          total: localHistory.total,
          transactions: resolvedTransactions,
        );
        _historyService.save(createHistory);
        howManyCreated++;
      }
    }

    SmLogger.debug(
      'Finished upload history',
      payload: {'created': howManyCreated},
    );
  }

  Future<void> loadPlans() async {
    SmLogger.debug('Init loading plans to Firebase', payload: {});
    final firebaseData = await _planService.fetch();
    final localData = await _getFileData(DataJsonClass.plans);
    int howManyCreated = 0;

    SmLogger.debug(
      'Preparing to upload plans',
      payload: {'firebase': firebaseData.length, 'local': localData.length},
    );

    for (final pJson in localData) {
      final localPlan = SalaryPlan.fromJson(pJson as Map<String, Object?>);
      final firebasePlan = firebaseData.where((p) => p.name == localPlan.name).firstOrNull;

      if (firebasePlan == null) {
        final createPlan = localPlan.copyWith(newId: true);
        _planService.save(createPlan);
        howManyCreated++;
      }
    }

    SmLogger.debug(
      'Finished upload plans',
      payload: {'created': howManyCreated},
    );
  }
}
