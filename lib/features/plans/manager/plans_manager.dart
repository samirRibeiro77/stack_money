import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';

class PlansManager {
  final PlanManagementService _service = PlanManagementService();

  final ValueNotifier<List<SalaryPlan>> _planDeck = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _showArchived = ValueNotifier(false);

  ValueListenable<bool> get isLoading => _isLoading;

  ValueListenable<List<SalaryPlan>> get planDeckNotifier => _planDeck;

  ValueListenable<bool> get showArchivedNotifier => _showArchived;

  List<SalaryPlan> get plans => _planDeck.value;

  void navigateToPlanDetails(BuildContext context, SalaryPlan plan) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    if (!isSecureActive) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => PlanEditScreen(plan: plan)))
          .then((_) => loadFirebasePlans());
    }
  }

  Future<void> loadFirebasePlans() async {
    try {
      _isLoading.value = true;
      final data = await _service.getAllSalaryPlans();
      _planDeck.value = data;
      _isLoading.value = false;
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Fail to fetch plans -> $e');
      _isLoading.value = false;
    }
  }

  void toggleShowArchived() {
    _showArchived.value = !_showArchived.value;
  }

  void initializeNewPlanSlot(BuildContext context) {
    final newPlan = SalaryPlan.empty(isActive: _planDeck.value.isEmpty);

    final updatedList = List<SalaryPlan>.from(_planDeck.value)
      ..insert(0, newPlan);
    _planDeck.value = updatedList;

    _service.saveSalaryPlan(newPlan);
    navigateToPlanDetails(context, newPlan);
  }

  void reorderFilteredPlans(
    List<SalaryPlan> filteredList,
    int oldIndex,
    int newIndex,
  ) {
    // Change RAM index
    final item = filteredList.removeAt(oldIndex);
    filteredList.insert(newIndex, item);

    final fullList = List<SalaryPlan>.from(_planDeck.value);

    // Remap positions
    for (int i = 0; i < filteredList.length; i++) {
      final updatedPlan = filteredList[i].copyWith(position: i + 1);
      filteredList[i] = updatedPlan;

      final mainIndex = fullList.indexWhere((p) => p.id == updatedPlan.id);
      if (mainIndex != -1) {
        fullList[mainIndex] = updatedPlan;
      }
    }

    _planDeck.value = fullList;

    // Save on Firebase
    for (final plan in filteredList) {
      _service.saveSalaryPlan(plan); //TODO: Create a batch update
    }
  }

  Future<void> archivePlan(String id, bool currentIsArchived) async {
    final bool nextState = !currentIsArchived;

    final updatedList = List<SalaryPlan>.from(_planDeck.value);
    final index = updatedList.indexWhere((p) => p.id == id);
    if (index != -1) {
      updatedList[index] = updatedList[index].copyWith(
        isArchived: nextState,
        isActive: nextState ? false : updatedList[index].isActive,
      );
      _planDeck.value = updatedList;
    }

    try {
      await _service.toggleArchiveSalaryPlan(id, nextState);
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Archive operation fail -> $e');
      loadFirebasePlans();
    }
  }

  Future<void> purgePlan(String id) async {
    final updatedList = List<SalaryPlan>.from(_planDeck.value);
    updatedList.removeWhere((p) => p.id == id);
    _planDeck.value = updatedList;

    try {
      await _service.purgeSalaryPlan(id);
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Purge operation fail -> $e');
      loadFirebasePlans();
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
