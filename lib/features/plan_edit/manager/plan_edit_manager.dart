import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/distribution_row.dart';
import 'package:stack_money/data/models/inflow_row.dart';
import 'package:stack_money/data/models/outflow_row.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/export_service.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';

class PlanEditManager {
  final PlanManagementService _planService = PlanManagementService();

  late final SalaryPlan _initialPlan;
  late final ValueNotifier<SalaryPlan> planNotifier;

  final _inflowExpandState = ValueNotifier(false);
  final _outflowExpandState = ValueNotifier(false);
  final _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;

  ValueListenable<bool> get inflowExpandState => _inflowExpandState;

  ValueListenable<bool> get outflowExpandState => _outflowExpandState;

  void toggleInflowExpand() =>
      _inflowExpandState.value = !_inflowExpandState.value;

  void toggleOutflowExpand() =>
      _outflowExpandState.value = !_outflowExpandState.value;

  PlanEditManager(SalaryPlan initialPlan) {
    _initialPlan = initialPlan;
    planNotifier = ValueNotifier(initialPlan);
    _ensureEmptyInflowRow();
    _ensureEmptyOutflowRow();
  }

  SalaryPlan get currentPlan => planNotifier.value;

  /// Retorna o plano limpo (sem as linhas vazias de placeholders do form)
  SalaryPlan _cleanPlan(SalaryPlan plan) {
    final cleanInflows = plan.inflows.where((e) => e.value > 0).toList();
    final cleanOutflows = plan.outflows
        .where((e) => e.value > 0 || e.name.isNotEmpty)
        .toList();

    return plan.copyWith(inflows: cleanInflows, outflows: cleanOutflows);
  }

  /// Verifica se houve qualquer alteração em relação ao snapshot inicial
  bool get isDirty {
    final cleanInitial = _cleanPlan(_initialPlan);
    final cleanCurrent = _cleanPlan(currentPlan);

    return cleanInitial != cleanCurrent;
  }

  /// Gera a lista do resumo exato estilo Git Status / Deep Diff Granular
  List<String> getDiffList(AppLocalizations l10n) {
    final changes = <String>[];
    final oldP = _cleanPlan(_initialPlan);
    final newP = _cleanPlan(currentPlan);

    // 1. Nome do Plano
    if (oldP.name != newP.name) {
      changes.add(l10n.planChangedName(newP.name, oldP.name));
    }

    // 2. Salário Base
    if (oldP.baseSalary != newP.baseSalary) {
      final oldVal = StackMoneyString.formatMoney(
        oldP.baseSalary,
        symbol: true,
      );
      final newVal = StackMoneyString.formatMoney(
        newP.baseSalary,
        symbol: true,
      );
      changes.add(l10n.planChangedBaseSalary(newVal, oldVal));
    }

    // 3. Entradas
    if (oldP.inflows.length != newP.inflows.length) {
      changes.add(
        l10n.planChangedItem(
          l10n.planChangedIncoming,
          newP.inflows.length,
          oldP.inflows.length,
        ),
      );
    }

    // 4. Saídas
    if (oldP.outflows.length != newP.outflows.length) {
      changes.add(
        l10n.planChangedItem(
          l10n.planChangedOutcoming,
          newP.outflows.length,
          oldP.outflows.length,
        ),
      );
    }

    // 5. Distribuições
    if (oldP.distributions.length != newP.distributions.length) {
      changes.add(
        l10n.planChangedItem(
          l10n.planChangedDistribution,
          newP.distributions.length,
          oldP.distributions.length,
        ),
      );
    }

    return changes;
  }

  int pendingChangesCount(AppLocalizations l10n) => getDiffList(l10n).length;

  String getDiffNote(AppLocalizations l10n) => getDiffList(l10n).join('\n');

  /// Salva todas as alterações pendentes no Firebase
  Future<bool> savePlan() async {
    if (!isDirty) return true;

    try {
      final cleanPlanToSave = _cleanPlan(currentPlan);
      await _planService.save(cleanPlanToSave);
      return true;
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to save plan',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'plan': currentPlan.toJson()},
        stackTrace: stack,
      );
      return false;
    }
  }

  void dispose() {
    _inflowExpandState.dispose();
    _outflowExpandState.dispose();
    _scrollController.dispose();
  }

  void updatePlanName(String newName) {
    planNotifier.value = currentPlan.copyWith(name: newName);
  }

  void updateBaseSalary(double value) {
    planNotifier.value = currentPlan.copyWith(baseSalary: value);
  }

  Future<void> copyPlan(BuildContext context) async {
    try {
      final copiedPlan = currentPlan.copyWith(
        newId: true,
        name: 'Copy of ${currentPlan.name}',
        isActive: false,
        isArchived: false,
        createdAt: Timestamp.now(),
      );

      await _planService.save(copiedPlan);

      if (context.mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PlanEditScreen(plan: copiedPlan)),
        );
      }
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to copy plan',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'plan': currentPlan.toJson()},
        stackTrace: stack,
      );
    }
  }

  Future<void> sharePlan(BuildContext context) async {
    try {
      ExportService().exportData([currentPlan.toJson()]);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to share plan',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'plan': currentPlan.toJson()},
        stackTrace: stack,
      );
    }
  }

  Future<void> archivePlan(BuildContext context) async {
    try {
      await _planService.toggleArchive(currentPlan.id, true);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to archive plan',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'plan': currentPlan.toJson()},
        stackTrace: stack,
      );
    }
  }

  Future<void> deletePlan(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SmDialog(
        message: l10n.deletePlanMessage,
        content: currentPlan.name,
        note: l10n.deletePlanNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirm == true) {
      try {
        await _planService.purge(currentPlan.id);
        if (context.mounted) Navigator.of(context).pop();
      } catch (e, stack) {
        StackMoneyException(
          message: 'Failed to delete plan',
          scope: ExceptionScope.business,
          payload: {'exception': e, 'plan': currentPlan.toJson()},
          stackTrace: stack,
        );
      }
    }
  }

  void _ensureEmptyInflowRow() {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (list.isEmpty || list.last.value > 0) {
      list.add(InflowRow.empty());
      planNotifier.value = currentPlan.copyWith(inflows: list);
    }
  }

  void updateInflow(int index, {InflowType? type, double? value, int? day}) {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (index >= 0 && index < list.length) {
      final inflow = list[index];

      list[index] = inflow.copyWith(type: type, value: value, day: day);

      planNotifier.value = currentPlan.copyWith(inflows: list);
      if (index == list.length - 1 && (value ?? 0) > 0) _ensureEmptyInflowRow();
    }
  }

  void removeInflow(int index, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final list = List<InflowRow>.from(currentPlan.inflows);
    if (list.length > 1) {
      final backupState = currentPlan;
      final inflow = list[index];
      final content = inflow.type == InflowType.percentageBase
          ? '${StackMoneyString.formatPercentage(inflow.value, decimal: 2)}${l10n.percentSignal}'
          : StackMoneyString.formatMoney(inflow.value, symbol: true);

      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => SmDialog(
          message: l10n.deleteInflowMessage,
          content: content,
          note: l10n.deleteInflowNote,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      );

      if (confirm == true) {
        list.removeAt(index);
        planNotifier.value = currentPlan.copyWith(inflows: list);
        _ensureEmptyInflowRow();

        _triggerUndoSnackBar(context, l10n.deletedInflow, backupState);
      }
    }
  }

  void _ensureEmptyOutflowRow() {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (list.isEmpty || list.last.value > 0 || list.last.name.isNotEmpty) {
      final int defaultDay = currentPlan.inflows.isNotEmpty
          ? currentPlan.inflows.first.day
          : 5;
      list.add(OutflowRow.empty(defaultDay: defaultDay));
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
      final outflow = list[index];

      list[index] = outflow.copyWith(
        name: name,
        type: type,
        value: value,
        targetDay: targetDay,
      );

      planNotifier.value = currentPlan.copyWith(outflows: list);
      if (index == list.length - 1 &&
          ((value ?? 0) > 0 || (name ?? '').isNotEmpty)) {
        _ensureEmptyOutflowRow();
      }
    }
  }

  void removeOutflow(int index, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (list.length > 1) {
      final backupState = currentPlan;
      final outflow = list[index];

      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => SmDialog(
          message: l10n.deleteOutflowMessage,
          content: outflow.name,
          note: l10n.deleteOutflowNote,
          onCancel: () => Navigator.of(context).pop(false),
          onConfirm: () => Navigator.of(context).pop(true),
        ),
      );

      if (confirm == true) {
        list.removeAt(index);
        planNotifier.value = currentPlan.copyWith(outflows: list);
        _ensureEmptyOutflowRow();

        _triggerUndoSnackBar(context, l10n.deletedOutflow, backupState);
      }
    }
  }

  void initializeNewDistributionSlot() {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    final int defaultDay = currentPlan.inflows.isNotEmpty
        ? currentPlan.inflows.first.day
        : 5;

    list.add(DistributionRow.empty(defaultDay: defaultDay));

    planNotifier.value = currentPlan.copyWith(distributions: list);
    _scrollToBottom();
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
      final distribution = list[index];

      list[index] = distribution.copyWith(
        category: cat,
        subCategory: sub,
        type: type,
        value: value,
        targetDay: targetDay,
      );

      planNotifier.value = currentPlan.copyWith(distributions: list);
    }
  }

  Future<bool?> removeDistributionConfirmation(
    String distributionName,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SmDialog(
        message: l10n.deleteDistributionMessage,
        content: distributionName,
        note: l10n.deleteDistributionNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  void removeDistribution(String id, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final backupState = currentPlan;

    final list = List<DistributionRow>.from(currentPlan.distributions);
    list.removeWhere((e) => e.id == id);
    planNotifier.value = currentPlan.copyWith(distributions: list);

    _triggerUndoSnackBar(context, l10n.deletedDistribution, backupState);
  }

  Future<void> togglePlanActivation() async {
    final bool newActiveState = !currentPlan.isActive;
    planNotifier.value = currentPlan.copyWith(isActive: newActiveState);

    await _planService.toggleActiveStatus(currentPlan.id, newActiveState);
  }

  void _triggerUndoSnackBar(
    BuildContext context,
    String message,
    SalaryPlan backup,
  ) {
    final l10n = AppLocalizations.of(context)!;

    SmSnackBar(
      message: message,
      type: SnackBarType.error,
      action: SnackBarAction(
        label: l10n.undo,
        onPressed: () {
          planNotifier.value = backup;
        },
      ),
    ).show(context);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
