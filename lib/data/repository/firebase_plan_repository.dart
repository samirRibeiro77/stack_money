import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebasePlanRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, dynamic>> _getPlanCollection() {
    return getUserDoc().collection(FirebaseKey.salaryPlans);
  }

  Future<List<SalaryPlan>> fetchAllPlans() async {
    try {
      SmLogger.debug('[PlanRepository] Fetching salary profiling roster...');

      final snapshot = await _getPlanCollection()
          .orderBy(ModelKey.createdAt, descending: true)
          .get();

      SmLogger.info(
        '[PlanRepository] Fetch success -> ${snapshot.docs.length} configuration maps loaded.',
      );
      return snapshot.docs
          .map((doc) => SalaryPlan.fromJson(doc.data()))
          .toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: '[PlanRepository] Error compiling plans ledger',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> savePlan(SalaryPlan plan) async {
    try {
      SmLogger.debug(
        '[PlanRepository] Opening synchronization transaction for UUID: ${plan.id}',
      );

      await _getPlanCollection()
          .doc(plan.id)
          .set(plan.toJson(), SetOptions(merge: true));

      SmLogger.info(
        '[PlanRepository] Document successfully synced: ${plan.id}',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: '[PlanRepository] Error saving plan structure configuration',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'id': plan.id,
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> updateActiveStatusInBatch(
    String targetPlanId,
    bool isActive,
  ) async {
    try {
      final collection = _getPlanCollection();

      if (isActive) {
        SmLogger.debug(
          '[BATCH_PROTOCOL] -> Activating profile $targetPlanId and flattening parallel profiles...',
        );
        final batch = firestore.batch();
        final querySnapshot = await collection.get();

        for (final doc in querySnapshot.docs) {
          final planId = doc.id;

          if (planId == targetPlanId) {
            batch.update(collection.doc(planId), {
              ModelKey.isActive: true,
              ModelKey.isArchived: false,
            });
          } else {
            batch.update(collection.doc(planId), {ModelKey.isActive: false});
          }
        }
        await batch.commit();
        SmLogger.info(
          '[BATCH_SUCCESS] -> Cascading unique profile allocation committed to core.',
        );
      } else {
        SmLogger.debug(
          '[DEACTIVATION_PROTOCOL] -> Toggling engine to inactive: $targetPlanId',
        );
        await collection.doc(targetPlanId).update({ModelKey.isActive: false});
        SmLogger.info(
          '[DEACTIVATION_SUCCESS] -> Profile configuration status update completed.',
        );
      }
    } catch (e, stack) {
      throw StackMoneyException(
        message: '[PlanRepository] Atomic batch state synchronization crashed',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'targetId': targetPlanId,
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      SmLogger.debug(
        '[ARCHIVE_STATUS] -> Flipping logical archive flag to $isArchived for UUID: $id',
      );
      final updates = <String, dynamic>{ModelKey.isArchived: isArchived};

      if (isArchived) {
        updates[ModelKey.isActive] = false;
      }

      await _getPlanCollection().doc(id).update(updates);
      SmLogger.info('[ARCHIVE_SUCCESS] -> Document visibility bit updated.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: '[PlanRepository] Archive status alteration protocol aborted',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'id': id,
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> purgePlan(String id) async {
    try {
      SmLogger.warning(
        '[PURGE_PROTOCOL] -> Initializing terminal deletion sequence on UUID: $id',
      );
      await _getPlanCollection().doc(id).delete();
      SmLogger.info(
        '[PURGE_SUCCESS] -> Document swept out from system infrastructure core.',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: '[PlanRepository] Hard purge execution failed on core cluster',
        scope: ExceptionScope.database,
        payload: {
          'timestamp': DateTime.now().toIso8601String(),
          'id': id,
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }
}
