import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/firebase_plan_repository.dart';

class PlanManagementService {
  final FirebasePlanRepository _repository = FirebasePlanRepository();

  Future<List<SalaryPlan>> getAllSalaryPlans() async {
    return await _repository.fetchAllPlans();
  }

  Future<void> saveSalaryPlan(SalaryPlan plan) async {
    await _repository.savePlan(plan);
  }

  Future<void> toggleArchiveSalaryPlan(String id, bool nextStatus) async {
    await _repository.updateArchiveStatus(id, nextStatus);
  }

  Future<void> purgeSalaryPlan(String id) async {
    await _repository.purgePlan(id);
  }
}
