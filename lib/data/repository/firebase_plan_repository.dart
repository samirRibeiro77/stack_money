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

  Future<List<SalaryPlan>> fetch() async {
    SmLogger.debug('Fetching salary plans', payload: {});

    try {
      final snapshot = await _collection
          .orderBy(ModelKey.position, descending: true)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No salary plan found');
      }

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

  Future<SalaryPlan?> fetchActivatedPlan() async {
    SmLogger.debug('Fetching current activated salary plan', payload: {});

    try {
      final snapshot = await _collection
          .where(ModelKey.isActive, isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        throw Exception('No activated salary plan found');
      }

      SmLogger.info('Found ${snapshot.docs.length} activated plan(s).');

      final plan = snapshot.docs.firstOrNull;
      if (plan == null) return null;

      return SalaryPlan.fromJson(plan.data());
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error searching the current activated plan',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Stream<List<SalaryPlan>> watch() {
    SmLogger.debug('Watching plans', payload: {});

    return _collection
        .orderBy(ModelKey.position, descending: true)
        .snapshots()
        .map((snapshot) {
      SmLogger.info(
        'Stream plans updated with ${snapshot.docs.length} entries.',
      );

      return snapshot.docs
          .map((doc) => SalaryPlan.fromJson(doc.data()))
          .toList();
    })
        .handleError((e, stack) {
      throw StackMoneyException(
        message: 'Error in plan timeline stream',
        scope: ExceptionScope.database,
        payload: {'exception': e},
        stackTrace: stack,
      );
    });
  }

  Future<void> save(SalaryPlan plan) async {
    SmLogger.debug('Saving salary plan', payload: plan.toJson());

    try {
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
    SmLogger.debug(
      'Activating profile and flattening parallel profiles...',
      payload: {'planId': targetPlanId},
    );

    try {
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
      SmLogger.warning(
        'Cascading unique profile allocation committed to core.',
      );
      await batch.commit();
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
    SmLogger.debug('Toggling plan to inactive', payload: {'id': targetPlanId});

    try {
      await _collection.doc(targetPlanId).update({ModelKey.isActive: false});
      SmLogger.warning('Profile configuration status update completed.');
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
    SmLogger.debug(
      'Flipping logical archive flag',
      payload: {'planId': id, 'isArchived': isArchived},
    );

    try {
      final updates = <String, Object?>{ModelKey.isArchived: isArchived};

      if (isArchived) {
        updates[ModelKey.isActive] = false;
      }

      await _collection.doc(id).update(updates);
      SmLogger.warning('Document visibility bit updated.');
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Archive status alteration protocol aborted',
        scope: ExceptionScope.database,
        payload: {'id': id, 'isArchived': isArchived, 'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> delete(String id) async {
    SmLogger.debug('Deleting salary plan', payload: {'id': id});

    try {
      await _collection.doc(id).delete();
      SmLogger.warning('Salary plan deleted.');
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
