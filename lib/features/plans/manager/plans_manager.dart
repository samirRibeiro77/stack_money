import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';

class PlansManager {
  final PlanManagementService _planService = PlanManagementService();

  final ValueNotifier<bool> _showArchived = ValueNotifier(false);

  ValueListenable<bool> get showArchivedNotifier => _showArchived;


  void navigateToPlanDetails(BuildContext context, SalaryPlan plan) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    if (!isSecureActive) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => PlanEditScreen(plan: plan)));
    }
  }

  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }

  void initializeNewPlanSlot(BuildContext context) {
    final newPlan = SalaryPlan.empty(isActive: AppCoordinator.instance.plans.value.isEmpty);

    _planService.save(newPlan);
    navigateToPlanDetails(context, newPlan);
  }

  void reorderFilteredPlans(
    List<SalaryPlan> filteredList,
    int oldIndex,
    int newIndex,
  ) {
    SmLogger.debug(
      'Reorder plan',
      payload: {'oldIndex': oldIndex, 'newIndex': newIndex},
    );

    // Change RAM index
    final item = filteredList.removeAt(oldIndex);
    filteredList.insert(newIndex, item);

    final fullList = List<SalaryPlan>.from(AppCoordinator.instance.plans.value);

    // Remap positions
    for (int i = 0; i < filteredList.length; i++) {
      final updatedPlan = filteredList[i].copyWith(position: i + 1);
      filteredList[i] = updatedPlan;

      final mainIndex = fullList.indexWhere((p) => p.id == updatedPlan.id);
      if (mainIndex != -1) {
        fullList[mainIndex] = updatedPlan;
      }
    }

    // Save on Firebase
    for (final plan in filteredList) {
      _planService.save(plan); //TODO: Create a batch update
    }
  }

  Future<void> archivePlan(String id, bool currentIsArchived) async {
    final bool nextState = !currentIsArchived;

    final updatedList = List<SalaryPlan>.from(AppCoordinator.instance.plans.value);
    final index = updatedList.indexWhere((p) => p.id == id);
    if (index != -1) {
      updatedList[index] = updatedList[index].copyWith(
        isArchived: nextState,
        isActive: nextState ? false : updatedList[index].isActive,
      );
    }

    try {
      await _planService.toggleArchive(id, nextState);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to archive plan',
        scope: ExceptionScope.business,
        payload: {
          'exception': e,
          'plan': {'id': id, 'nextState': nextState},
        },
        stackTrace: stack,
      );
    }
  }

  Future<void> purgePlan(String id) async {
    final updatedList = List<SalaryPlan>.from(AppCoordinator.instance.plans.value);
    updatedList.removeWhere((p) => p.id == id);

    try {
      await _planService.purge(id);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to delete plans',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'planId': id},
        stackTrace: stack,
      );
    }
  }

  Future<bool?> showTerminalConfirmDialog(
    String planName,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SmDialog(
        message: l10n.deletePlanMessage,
        content: planName,
        note: l10n.deletePlanNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }
}
