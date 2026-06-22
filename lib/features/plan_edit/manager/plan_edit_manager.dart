import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_dialog.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/models/inflow_row.dart';
import 'package:stack_money/data/models/outflow_row.dart';
import 'package:stack_money/data/models/distribution_row.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';
import 'package:uuid/uuid.dart';

class PlanEditManager {
  final PlanManagementService _service = PlanManagementService();
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
    planNotifier = ValueNotifier(initialPlan);
    _ensureEmptyInflowRow();
    _ensureEmptyOutflowRow();
  }

  SalaryPlan get currentPlan => planNotifier.value;

  void dispose() {
    _inflowExpandState.dispose();
    _outflowExpandState.dispose();
    _scrollController.dispose();
  }

  void updatePlanName(String newName) {
    planNotifier.value = currentPlan.copyWith(name: newName);
    _autoSave();
  }

  void updateBaseSalary(double value) {
    planNotifier.value = currentPlan.copyWith(baseSalary: value);
    _autoSave();
  }

  // 👑 PROTOCOLO DE DUPLICAÇÃO ATÔMICA & REDIRECIONAMENTO DE PILHA
  Future<void> copyPlan(BuildContext context) async {
    try {
      final String newId = const Uuid().v4();
      final copiedPlan = currentPlan.copyWith(
        id: newId,
        name: 'Copy of ${currentPlan.name}',
        isActive: false,
        isArchived: false,
        createdAt: DateTime.now(),
      );

      await _service.saveSalaryPlan(copiedPlan);

      if (context.mounted) {
        // 🚀 Substitui o editor atual pelo novo, limpando o histórico para o "voltar" cair na listagem principal
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => PlanEditScreen(plan: copiedPlan)),
        );
      }
    } catch (e) {
      debugPrint('❌ [COPY_PLAN_FAIL] -> $e');
    }
  }

  // 📦 PROTOCOLO ARQUIVAR VIA MENU
  Future<void> archivePlan(BuildContext context) async {
    try {
      await _service.toggleArchiveSalaryPlan(currentPlan.id, true);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      debugPrint('❌ [ARCHIVE_FAIL] -> $e');
    }
  }

  // 🗑️ PROTOCOLO PURGE PERMANENTE VIA MENU
  Future<void> deletePlan(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StackMoneyDialog(
        message: l10n.deletePlanMessage,
        content: currentPlan.name,
        note: l10n.deletePlanNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirm == true) {
      try {
        await _service.purgeSalaryPlan(currentPlan.id);
        if (context.mounted) Navigator.of(context).pop();
      } catch (e) {
        debugPrint('❌ [MENU_PURGE_FAIL] -> $e');
      }
    }
  }

  // 🟢 INFLOW ENGINE (Com suporte a Undo)
  void _ensureEmptyInflowRow() {
    final list = List<InflowRow>.from(currentPlan.inflows);
    if (list.isEmpty || list.last.value > 0) {
      list.add(
        InflowRow(
          id: const Uuid().v4(),
          type: InflowType.percentageBase,
          value: 0.0,
          day: 5,
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
        builder: (context) => StackMoneyDialog(
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
        _autoSave();

        _triggerUndoSnackBar(context, l10n.deletedInflow, backupState);
      }
    }
  }

  // 🔴 OUTFLOW ENGINE (Com suporte a Undo)
  void _ensureEmptyOutflowRow() {
    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (list.isEmpty || list.last.value > 0 || list.last.name.isNotEmpty) {
      final int defaultDay = currentPlan.inflows.isNotEmpty
          ? currentPlan.inflows.first.day
          : 5;
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

  void removeOutflow(int index, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final list = List<OutflowRow>.from(currentPlan.outflows);
    if (list.length > 1) {
      final backupState = currentPlan;
      final outflow = list[index];

      final confirm = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => StackMoneyDialog(
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
        _autoSave();

        _triggerUndoSnackBar(context, l10n.deletedOutflow, backupState);
      }
    }
  }

  // ⚡ DISTRIBUTION ENGINE (Com suporte a Undo)
  void initializeNewDistributionSlot() {
    final list = List<DistributionRow>.from(currentPlan.distributions);
    final int defaultDay = currentPlan.inflows.isNotEmpty
        ? currentPlan.inflows.first.day
        : 5;

    list.add(DistributionRow.empty(defaultDay: defaultDay));

    planNotifier.value = currentPlan.copyWith(distributions: list);
    _autoSave();
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

  Future<bool?> removeDistributionConfirmation(
      String distributionName,
      BuildContext context,
      ) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StackMoneyDialog(
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
    final distribution = currentPlan.distributions
        .where((d) => d.id == id)
        .firstOrNull;

    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => StackMoneyDialog(
        message: l10n.deleteDistributionMessage,
        content: distribution?.name,
        note: l10n.deleteDistributionNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );

    if (confirm == true) {
      final list = List<DistributionRow>.from(currentPlan.distributions);
      list.removeWhere((e) => e.id == id);
      planNotifier.value = currentPlan.copyWith(distributions: list);
      _autoSave();

      _triggerUndoSnackBar(context, l10n.deletedDistribution, backupState);
    }
  }

  Future<void> triggerPlanActivation() async {
    planNotifier.value = currentPlan.copyWith(isActive: true);
    await _service.setActivePlanInBatch(currentPlan.id);
  }

  // 🛠️ MÓDULO SNACKBAR RECOVERY INTERCEPTOR
  void _triggerUndoSnackBar(
    BuildContext context,
    String message,
    SalaryPlan backup,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: StackMoneyTheme.carbonGrey,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(AppSizes.x6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.x4),
        ),
        content: Text(
          StackMoneyString.formatTitle(message),
          style: textTheme.bodySmall,
        ),
        action: SnackBarAction(
          label: '[${StackMoneyString.formatTitle(l10n.undo)}]',
          textColor: StackMoneyTheme.cyanNeon,
          onPressed: () {
            planNotifier.value = backup;
            _autoSave();
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
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
