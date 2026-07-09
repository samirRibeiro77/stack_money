import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/data/helper/firebase_key.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/base_firebase_repository.dart';

class FirebasePlanRepository extends BaseFirebaseRepository {
  CollectionReference<Map<String, Object?>> get _collection =>
      getUserDoc().collection(FirebaseKey.salaryPlans);

  Future<List<SalaryPlan>> fetchAllPlans() async {
    try {
      SmLogger.debug(
        'Fetching salary profiling roster...',
        where: 'PlanRepository',
      );

      final snapshot = await _collection
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
        payload: {'exception': e},
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

      await _collection
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
        payload: {'plan': plan.toJson(), 'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> updateActiveStatusInBatch(
    String targetPlanId,
    bool isActive,
  ) async {
    try {
      if (isActive) {
        await _activatePlan(targetPlanId);
      } else {
        await _deactivatePlan(targetPlanId);
      }
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Atomic batch state synchronization crashed',
        where: 'PlanRepository',
        scope: ExceptionScope.database,
        payload: {
          'targetId': targetPlanId,
          'isActive': isActive,
          'exception': e,
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> _deactivatePlan(String targetPlanId) async {
    SmLogger.debug(
      'Toggling engine to inactive: $targetPlanId',
      where: 'PlanRepository',
    );
    await _collection.doc(targetPlanId).update({ModelKey.isActive: false});
    SmLogger.info(
      'Profile configuration status update completed.',
      where: 'PlanRepository',
    );
  }

  Future<void> _activatePlan(String targetPlanId) async {
    SmLogger.debug(
      'Activating profile $targetPlanId and flattening parallel profiles...',
      where: 'PlanRepository',
    );
    final batch = firestore.batch();
    final querySnapshot = await _collection.get();

    for (final doc in querySnapshot.docs) {
      if (doc.id == targetPlanId) {
        batch.update(_collection.doc(doc.id), {
          ModelKey.isActive: true,
          ModelKey.isArchived: false,
        });
      } else {
        batch.update(_collection.doc(doc.id), {ModelKey.isActive: false});
      }
    }
    await batch.commit();
    SmLogger.info(
      'Cascading unique profile allocation committed to core.',
      where: 'PlanRepository',
    );
  }

  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      SmLogger.debug(
        'Flipping logical archive flag to $isArchived for UUID: $id',
        where: 'PlanRepository',
      );
      final updates = <String, Object?>{ModelKey.isArchived: isArchived};

      if (isArchived) {
        updates[ModelKey.isActive] = false;
      }

      await _collection.doc(id).update(updates);
      SmLogger.info(
        'Document visibility bit updated.',
        where: 'PlanRepository',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Archive status alteration protocol aborted',
        where: 'PlanRepository',
        scope: ExceptionScope.database,
        payload: {'id': id, 'isArchived': isArchived, 'exception': e},
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
      await _collection.doc(id).delete();
      SmLogger.info(
        'Document swept out from system infrastructure core.',
        where: 'PlanRepository',
      );
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Hard purge execution failed on core cluster',
        where: 'PlanRepository',
        scope: ExceptionScope.database,
        payload: {'id': id, 'exception': e},
        stackTrace: stack,
      );
    }
  }
}
