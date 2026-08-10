import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/firebase_plan_repository.dart';

class PlanManagementService {
  final FirebasePlanRepository _repository = FirebasePlanRepository();

  Future<Result<List<SalaryPlan>>> fetch() async {
    try {
      final salaryList = await _repository.fetch();
      return Success(salaryList);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching plans',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<SalaryPlan?>> fetchActivated() async {
    try {
      final salaryPlan = await _repository.fetchActivatedPlan();
      return Success(salaryPlan);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching active plan',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Stream<List<SalaryPlan>> watch() {
    return _repository.watch();
  }

  Future<Result<bool>> isMoneySprintAvailableToday() async {
    try {
      final planResult = await fetchActivated();
      switch (planResult) {
        case Success(data: final plan):
          if (plan == null) return Success(false);
          return Success(
            plan.inflows.any((inflow) => inflow.day == DateTime.now().day),
          );
        case Failure(exception: final error):
          throw error;
      }
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error defining if there\'s an available sprint today',
          scope: ExceptionScope.business,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> save(SalaryPlan plan) async {
    try {
      await _repository.save(plan);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving salary plan',
          scope: ExceptionScope.business,
          payload: plan.toJson(),
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> saveBatch(List<SalaryPlan> salaryList) async {
    try {
      await _repository.saveBatch(salaryList);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error saving salary plan list',
          scope: ExceptionScope.service,
          exception: e as Exception,
          payload: {'salaryList': salaryList.map((s) => s.toJson()).toList()},
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> toggleArchive(String id, bool nextStatus) async {
    try {
      await _repository.updateArchiveStatus(id, nextStatus);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error toggling plan to active',
          scope: ExceptionScope.business,
          payload: {'id': id, 'nextStatus': nextStatus},
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> purge(String id) async {
    try {
      await _repository.delete(id);
      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error deleting plan',
          scope: ExceptionScope.business,
          payload: {'id': id},
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<void>> toggleActiveStatus(
    String targetPlanId,
    bool isActive,
  ) async {
    try {
      if (isActive) {
        await _repository.activatePlan(targetPlanId);
      } else {
        await _repository.deactivatePlan(targetPlanId);
      }

      return Success(null);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error deleting plan',
          scope: ExceptionScope.business,
          payload: {'id': targetPlanId, 'isActive': isActive},
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }
}
