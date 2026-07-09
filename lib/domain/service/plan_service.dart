import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/firebase_plan_repository.dart';

class PlanManagementService {
  final FirebasePlanRepository _repository = FirebasePlanRepository();

  Future<List<SalaryPlan>> fetch() async {
    return await _repository.fetchAllPlans();
  }

  Future<void> save(SalaryPlan plan) async {
    await _repository.savePlan(plan);
  }

  Future<void> toggleArchive(String id, bool nextStatus) async {
    await _repository.updateArchiveStatus(id, nextStatus);
  }

  Future<void> purge(String id) async {
    await _repository.purgePlan(id);
  }

  Future<void> toggleActiveStatus(String targetPlanId, bool isActive) async {
    if (isActive) {
      await _repository.activatePlan(targetPlanId);
    }
    else {
      await _repository.deactivatePlan(targetPlanId);
    }
  }
}