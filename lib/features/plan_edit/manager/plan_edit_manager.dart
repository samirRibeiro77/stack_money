import 'package:flutter/foundation.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/models/inflow_row.dart';
import 'package:stack_money/data/models/outflow_row.dart';
import 'package:stack_money/data/models/distribution_row.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:uuid/uuid.dart';

class PlanEditManager {
  final PlanManagementService _service = PlanManagementService();
  late final ValueNotifier<SalaryPlan> planNotifier;

  PlanEditManager(SalaryPlan initialPlan) {
    // Inicializa o notifier com o plano vindo da listagem
    planNotifier = ValueNotifier(initialPlan);
    _ensureEmptyInflowRow();
  }

  SalaryPlan get currentPlan => planNotifier.value;

  // 🟢 INFLOW ENGINE (Lógica de Linhas Infinitas)
  void _ensureEmptyInflowRow() {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (list.isEmpty || list.last.value > 0) {
      list.add(const InflowRow(value: 0.0, day: 5));
      planNotifier.value = currentPlan.copyWith(inflows: list);
    }
  }

  void updateInflow(int index, double value, int day) {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (index >= 0 && index < list.length) {
      list[index] = InflowRow(value: value, day: day);
      planNotifier.value = currentPlan.copyWith(inflows: list);

      // Se preencheu a última linha ativa, brota uma nova vazia abaixo
      if (index == list.length - 1 && value > 0) {
        _ensureEmptyInflowRow();
      }
      _autoSave();
    }
  }

  void removeInflow(int index) {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (list.length > 1) {
      list.removeAt(index);
      planNotifier.value = currentPlan.copyWith(inflows: list);
      _ensureEmptyInflowRow();
      _autoSave();
    }
  }

  // 🔴 OUTFLOW ENGINE
  void addOutflow() {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    // Pega o primeiro dia disponível de receita como target padrão
    final int defaultDay = currentPlan.inflows.isNotEmpty ? currentPlan.inflows.first.day : 5;
    list.add(OutflowRow(name: '', value: 0.0, targetDay: defaultDay));
    planNotifier.value = currentPlan.copyWith(outflows: list);
    _autoSave();
  }

  void updateOutflow(int index, {String? name, double? value, int? targetDay}) {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (index >= 0 && index < list.length) {
      list[index] = OutflowRow(
        name: name ?? list[index].name,
        value: value ?? list[index].value,
        targetDay: targetDay ?? list[index].targetDay,
      );
      planNotifier.value = currentPlan.copyWith(outflows: list);
      _autoSave();
    }
  }

  void removeOutflow(int index) {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    list.removeAt(index);
    planNotifier.value = currentPlan.copyWith(outflows: list);
    _autoSave();
  }

  // ⚡ DISTRIBUTION ENGINE
  void initializeNewDistributionSlot() {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    final int defaultDay = currentPlan.inflows.isNotEmpty ? currentPlan.inflows.first.day : 5;

    list.insert(0, DistributionRow(
      id: const Uuid().v4(),
      category: '',
      subCategory: '',
      type: AllocationType.fixed,
      value: 0.0,
      targetDay: defaultDay,
    ));

    planNotifier.value = currentPlan.copyWith(distributions: list);
    _autoSave();
  }

  void updateDistribution(int index, {String? cat, String? sub, AllocationType? type, double? value, int? targetDay}) {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    if (index >= 0 && index < list.length) {
      list[index] = DistributionRow(
        id: list[index].id,
        category: cat ?? list[index].category,
        subCategory: sub ?? list[index].subCategory,
        type: type ?? list[index].type,
        value: value ?? list[index].value,
        targetDay: targetDay ?? list[index].targetDay,
      );
      planNotifier.value = currentPlan.copyWith(distributions: list);
      _autoSave();
    }
  }

  void removeDistribution(int index) {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    list.removeAt(index);
    planNotifier.value = currentPlan.copyWith(distributions: list);
    _autoSave();
  }

  // ⚙️ ACTIVATION TRIGGER DIRECT FROM EDITOR
  Future<void> triggerPlanActivation() async {
    planNotifier.value = currentPlan.copyWith(isActive: true);
    await _service.saveSalaryPlan(currentPlan);
  }

  void _autoSave() {
    // Limpa linhas fantasmas de inflow antes de mandar pro Firebase
    final cleanInflows = currentPlan.inflows.where((e) => e.value > 0).toList();
    final cleanPlan = currentPlan.copyWith(inflows: cleanInflows);

    _service.saveSalaryPlan(cleanPlan).catchError((err) {
      debugPrint('❌ [AUTOSAVE_FAIL] -> Plan edit sync engine failed: $err');
    });
  }
}