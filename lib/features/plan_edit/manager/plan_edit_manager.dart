import 'package:flutter/foundation.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/models/inflow_row.dart';
import 'package:stack_money/data/models/outflow_row.dart';
import 'package:stack_money/data/models/distribution_row.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:uuid/uuid.dart';

class PlanEditManager {
  final PlanManagementService _service = PlanManagementService();
  late final ValueNotifier<SalaryPlan> planNotifier;

  final _inflowExpandState = ValueNotifier(false);
  final _outflowExpandState = ValueNotifier(false);

  ValueListenable<bool> get inflowExpandState => _inflowExpandState;

  ValueListenable<bool> get outflowExpandState => _outflowExpandState;

  void toggleInflowExpand() =>
      _inflowExpandState.value = !_inflowExpandState.value;

  void toggleOutflowExpand() =>
      _outflowExpandState.value = !_outflowExpandState.value;

  PlanEditManager(SalaryPlan initialPlan) {
    planNotifier = ValueNotifier(initialPlan);
    _ensureEmptyInflowRow();
    _ensureEmptyOutflowRow();
  }

  SalaryPlan get currentPlan => planNotifier.value;

  void updatePlanName(String newName) {
    planNotifier.value = currentPlan.copyWith(name: newName);
    _autoSave();
  }

  void updateBaseSalary(double value) {
    planNotifier.value = currentPlan.copyWith(baseSalary: value);
    _autoSave();
  }

  // 🟢 INFLOW ENGINE
  void _ensureEmptyInflowRow() {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (list.isEmpty || list.last.value > 0) {
      list.add(
        InflowRow(
          id: const Uuid().v4(),
          type: InflowType.percentageBase,
          value: 0.0,
          day: 0,
        ),
      );
      planNotifier.value = currentPlan.copyWith(inflows: list);
    }
  }

  void updateInflow(int index, {InflowType? type, double? value, int? day}) {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (index >= 0 && index < list.length) {
      list[index] = InflowRow(
        id: list[index].id,
        type: type ?? list[index].type,
        value: value ?? list[index].value,
        day: day ?? list[index].day,
      );
      planNotifier.value = currentPlan.copyWith(inflows: list);
      if (index == list.length - 1 && (value ?? 0) > 0) _ensureEmptyInflowRow();
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

  // 🔴 OUTFLOW ENGINE (Infinite row UX)
  void _ensureEmptyOutflowRow() {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (list.isEmpty || list.last.value > 0 || list.last.name.isNotEmpty) {
      final int defaultDay = currentPlan.inflows.isNotEmpty
          ? currentPlan.inflows.first.day
          : 0;
      list.add(
        OutflowRow(
          id: const Uuid().v4(),
          name: '',
          type: DeductionType.fixed,
          value: 0.0,
          targetDay: defaultDay,
        ),
      );
      planNotifier.value = currentPlan.copyWith(outflows: list);
    }
  }

  void updateOutflow(
    int index, {
    String? name,
    DeductionType? type,
    double? value,
    int? targetDay,
  }) {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (index >= 0 && index < list.length) {
      list[index] = OutflowRow(
        id: list[index].id,
        name: name ?? list[index].name,
        type: type ?? list[index].type,
        value: value ?? list[index].value,
        targetDay: targetDay ?? list[index].targetDay,
      );
      planNotifier.value = currentPlan.copyWith(outflows: list);
      if (index == list.length - 1 &&
          ((value ?? 0) > 0 || (name ?? '').isNotEmpty)) {
        _ensureEmptyOutflowRow();
      }
      _autoSave();
    }
  }

  void removeOutflow(int index) {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (list.length > 1) {
      list.removeAt(index);
      planNotifier.value = currentPlan.copyWith(outflows: list);
      _ensureEmptyOutflowRow();
      _autoSave();
    }
  }

  // ⚡ DISTRIBUTION ENGINE
  void initializeNewDistributionSlot() {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    final int defaultDay = currentPlan.inflows.isNotEmpty
        ? currentPlan.inflows.first.day
        : 0;

    // BUG FIX 2: Nasce com strings vazias e ID único para travar o ciclo de reaproveitamento de estado
    list.insert(
      0,
      DistributionRow(
        id: const Uuid().v4(),
        category: '',
        subCategory: '',
        type: AllocationType.fixed,
        value: 0.0,
        targetDay: defaultDay,
      ),
    );

    planNotifier.value = currentPlan.copyWith(distributions: list);
    _autoSave();
  }

  void updateDistribution(
    int index, {
    String? cat,
    String? sub,
    AllocationType? type,
    double? value,
    int? targetDay,
  }) {
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

  void removeDistribution(String id) {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    list.removeWhere((e) => e.id == id);
    planNotifier.value = currentPlan.copyWith(distributions: list);
    _autoSave();
  }

  Future<void> triggerPlanActivation() async {
    planNotifier.value = currentPlan.copyWith(isActive: true);
    await _service.setActivePlanInBatch(currentPlan.id);
  }

  void _autoSave() {
    final cleanInflows = currentPlan.inflows.where((e) => e.value > 0).toList();
    final cleanOutflows = currentPlan.outflows
        .where((e) => e.value > 0 || e.name.isNotEmpty)
        .toList();
    final cleanPlan = currentPlan.copyWith(
      inflows: cleanInflows,
      outflows: cleanOutflows,
    );

    _service.saveSalaryPlan(cleanPlan).catchError((err) {
      debugPrint('❌ [AUTOSAVE_FAIL] -> Sync error: $err');
    });
  }
}
