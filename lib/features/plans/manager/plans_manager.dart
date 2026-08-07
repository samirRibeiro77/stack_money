import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/error/error_screen.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';

class PlansManager {
  final PlanManagementService _planService = PlanManagementService();
  final BuildContext _context;

  final ValueNotifier<bool> _showArchived = ValueNotifier(false);

  ValueListenable<bool> get showArchivedNotifier => _showArchived;

  PlansManager(this._context) {
    final initialArchived =
        AppCoordinator.instance.user.value.preferences.cardExpand;
    if (_showArchived.value != initialArchived) {
      toggleShowArchived();
    }
  }

  void navigateToPlanDetails(SalaryPlan plan) {
    final isSecureActive = SecurityProvider.isSecureOf(_context);

    if (!isSecureActive) {
      Navigator.of(
        _context,
      ).push(MaterialPageRoute(builder: (_) => PlanEditScreen(plan: plan)));
    }
  }

  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }

  void initializeNewPlanSlot() {
    final newPlan = SalaryPlan.empty();

    _planService
        .save(newPlan)
        .then(
          (result) => result.fold(
            onSuccess: (_) => navigateToPlanDetails(newPlan),
            onFailure: (e) {
              if (_context.mounted) {
                final l10n = AppLocalizations.of(_context)!;
                SmSnackBar(
                  message: l10n.failedInitializingNewSlot,
                  type: SnackBarType.error,
                ).show(_context);
              }
            },
          ),
        );
  }

  void reorderFilteredPlans(
    BuildContext _context,
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
    _planService
        .saveBatch(filteredList)
        .then(
          (result) => result.fold(
            onSuccess: (_) {},
            onFailure: (e) {
              if (_context.mounted) {
                _context.go(ErrorScreen.route, extra: e);
              }
            },
          ),
        );
  }

  Future<void> archivePlan(String id, bool currentIsArchived) async {
    final bool nextState = !currentIsArchived;

    final updatedList = List<SalaryPlan>.from(
      AppCoordinator.instance.plans.value,
    );
    final index = updatedList.indexWhere((p) => p.id == id);
    if (index != -1) {
      updatedList[index] = updatedList[index].copyWith(
        isArchived: nextState,
        isActive: nextState ? false : updatedList[index].isActive,
      );
    }

    _planService
        .toggleArchive(id, nextState)
        .then(
          (result) => result.fold(
            onSuccess: (_) {},
            onFailure: (e) {
              if (_context.mounted) {
                final l10n = AppLocalizations.of(_context)!;
                SmSnackBar(
                  message: l10n.failedArchivePlan,
                  type: SnackBarType.error,
                ).show(_context);
              }
            },
          ),
        );
  }

  Future<void> purgePlan(String id) async {
    final updatedList = List<SalaryPlan>.from(
      AppCoordinator.instance.plans.value,
    );
    updatedList.removeWhere((p) => p.id == id);

    _planService
        .purge(id)
        .then(
          (result) => result.fold(
            onSuccess: (_) {},
            onFailure: (e) {
              if (_context.mounted) {
                final l10n = AppLocalizations.of(_context)!;
                SmSnackBar(
                  message: l10n.failedPurgePlan,
                  type: SnackBarType.error,
                ).show(_context);
              }
            },
          ),
        );
  }

  Future<bool?> showTerminalConfirmDialog(String planName) {
    final l10n = AppLocalizations.of(_context)!;

    return showDialog<bool>(
      context: _context,
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
