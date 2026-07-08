import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
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
      SmLogger.debug(
        'Fetching salary profiling roster...',
        where: 'PlanRepository',
      );

      final snapshot = await _getPlanCollection()
          .orderBy(ModelKey.createdAt, descending: true)
          .get();

      SmLogger.info(
        'Fetch success -> ${snapshot.docs.length} configuration maps loaded.',
        where: 'PlanRepository',
      );
      return snapshot.docs
          .map((doc) => SalaryPlan.fromJson(doc.data()))
          .toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error compiling plans ledger',
        where: 'PlanRepository',
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
        'Opening synchronization transaction for UUID: ${plan.id}',
        where: 'PlanRepository',
      );

      await _getPlanCollection()
          .doc(plan.id)
          .set(plan.toJson(), SetOptions(merge: true));

      SmLogger.info(
        'Document successfully synced: ${plan.id}',
        where: 'PlanRepository',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error saving plan structure configuration',
        where: 'PlanRepository',
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
          'Activating profile $targetPlanId and flattening parallel profiles...',
          where: 'PlanRepository',
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
          'Cascading unique profile allocation committed to core.',
          where: 'PlanRepository',
        );
      } else {
        SmLogger.debug(
          'Toggling engine to inactive: $targetPlanId',
          where: 'PlanRepository',
        );
        await collection.doc(targetPlanId).update({ModelKey.isActive: false});
        SmLogger.info(
          'Profile configuration status update completed.',
          where: 'PlanRepository',
        );
      }
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Atomic batch state synchronization crashed',
        where: 'PlanRepository',
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
        'Flipping logical archive flag to $isArchived for UUID: $id',
        where: 'PlanRepository',
      );
      final updates = <String, dynamic>{ModelKey.isArchived: isArchived};

      if (isArchived) {
        updates[ModelKey.isActive] = false;
      }

      await _getPlanCollection().doc(id).update(updates);
      SmLogger.info(
        'Document visibility bit updated.',
        where: 'PlanRepository',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Archive status alteration protocol aborted',
        where: 'PlanRepository',
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
        'Initializing terminal deletion sequence on UUID: $id',
        where: 'PlanRepository',
      );
      await _getPlanCollection().doc(id).delete();
      SmLogger.info(
        'Document swept out from system infrastructure core.',
        where: 'PlanRepository',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Hard purge execution failed on core cluster',
        where: 'PlanRepository',
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
