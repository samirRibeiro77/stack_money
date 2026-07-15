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
      SmLogger.debug('Fetching salary profiling roster...');

      final snapshot = await _collection
          .orderBy(ModelKey.createdAt, descending: true)
          .get();

      SmLogger.info(
        'Fetch plans completed with ${snapshot.docs.length} entries.',
      );
      return snapshot.docs
          .map((doc) => SalaryPlan.fromJson(doc.data()))
          .toList();
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error compiling plans ledger',
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
      );

      await _collection
          .doc(plan.id)
          .set(plan.toJson(), SetOptions(merge: true));

      SmLogger.info('Document successfully synced: ${plan.id}');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error saving plan structure configuration',
        scope: ExceptionScope.database,
        payload: {'plan': plan.toJson(), 'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> activatePlan(String targetPlanId) async {
    try {
      SmLogger.debug(
        'Activating profile $targetPlanId and flattening parallel profiles...',
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
      SmLogger.info('Cascading unique profile allocation committed to core.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to batch activate plan',
        scope: ExceptionScope.database,
        payload: {'planId': targetPlanId, 'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> deactivatePlan(String targetPlanId) async {
    try {
      SmLogger.debug('Toggling plan to inactive: $targetPlanId');
      await _collection.doc(targetPlanId).update({ModelKey.isActive: false});
      SmLogger.info('Profile configuration status update completed.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Failed to deactivate plan',
        scope: ExceptionScope.database,
        payload: {'planId': targetPlanId, 'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> updateArchiveStatus(String id, bool isArchived) async {
    try {
      SmLogger.debug(
        'Flipping logical archive flag to $isArchived for UUID: $id',
      );
      final updates = <String, Object?>{ModelKey.isArchived: isArchived};

      if (isArchived) {
        updates[ModelKey.isActive] = false;
      }

      await _collection.doc(id).update(updates);
      SmLogger.info('Document visibility bit updated.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Archive status alteration protocol aborted',
        scope: ExceptionScope.database,
        payload: {'id': id, 'isArchived': isArchived, 'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> purgePlan(String id) async {
    try {
      SmLogger.warning('Initializing terminal deletion sequence on UUID: $id');
      await _collection.doc(id).delete();
      SmLogger.info('Document swept out from system infrastructure core.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Hard purge execution failed on core cluster',
        scope: ExceptionScope.database,
        payload: {'id': id, 'exception': e},
        stackTrace: stack,
      );
    }
  }
}
