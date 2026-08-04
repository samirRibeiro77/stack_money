import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/firebase_plan_repository.dart';

class PlanManagementService {
  final FirebasePlanRepository _repository = FirebasePlanRepository();

  Future<List<SalaryPlan>> fetch() async {
    return await _repository.fetch();
  }

  Future<SalaryPlan?> fetchActivated() async {
    return await _repository.fetchActivatedPlan();
  }

  Future<bool> isMoneySprintAvailableToday() async {
    try {
      final plan = await fetchActivated();
      if (plan == null) return false;

      return plan.inflows.any((inflow) => inflow.day == DateTime.now().day);
    } catch (e, stack) {
      throw StackMoneyException(
        message: 'Error defining if there\'s an available sprint today',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );
    }
  }

  Future<void> save(SalaryPlan plan) async {
    await _repository.save(plan);
  }

  Future<void> toggleArchive(String id, bool nextStatus) async {
    await _repository.updateArchiveStatus(id, nextStatus);
  }

  Future<void> purge(String id) async {
    await _repository.delete(id);
  }

  Future<void> toggleActiveStatus(String targetPlanId, bool isActive) async {
    if (isActive) {
      await _repository.activatePlan(targetPlanId);
    } else {
      await _repository.deactivatePlan(targetPlanId);
    }
  }
}
