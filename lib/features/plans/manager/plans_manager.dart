import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/plan_service.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:uuid/uuid.dart';

class PlansManager {
  final PlanManagementService _service = PlanManagementService();

  final ValueNotifier<List<SalaryPlan>> _planDeck = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);

  ValueListenable<bool> get isLoading => _isLoading;
  ValueListenable<List<SalaryPlan>> get planDeckNotifier => _planDeck;

  List<SalaryPlan> get plans => _planDeck.value;

  Future<void> loadFirebasePlans() async {
    try {
      _isLoading.value = true;
      final data = await _service.getActiveSalaryPlans();
      _planDeck.value = data;
      _isLoading.value = false;
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Fail to fetch plans -> $e');
      _isLoading.value = false;
    }
  }

  /// ➕ MATRIX PLAN INSERTION: Cria um plano fantasma com UUID nativo e joga no topo
  void initializeNewPlanSlot() {
    final newUuid = const Uuid().v4();
    final newPlan = SalaryPlan(
      id: newUuid,
      name: 'New plan',
      isActive: _planDeck.value.isEmpty, // Se for o primeiro do app, nasce ativo
      isArchived: false,
      sortOrder: 0,
      createdAt: DateTime.now(),
      inflows: [],
      outflows: [],
      distributions: [],
    );

    // Como as regras determinam reordenação sequencial, empurra os antigos para baixo
    final updatedList = List<SalaryPlan>.from(_planDeck.value);

    // Se o novo for ativo, desativa o antigo topo localmente antes de salvar
    if (newPlan.isActive && updatedList.isNotEmpty) {
      updatedList[0] = updatedList[0].copyWith(isActive: false);
    }

    updatedList.insert(0, newPlan);

    // Corrige os índices numéricos de sort_order das linhas remanescentes
    final List<SalaryPlan> sequentialList = [];
    for (int i = 0; i < updatedList.length; i++) {
      sequentialList.add(updatedList[i].copyWith(sortOrder: i));
    }

    _planDeck.value = sequentialList;
    _service.saveSalaryPlan(newPlan);
  }

  /// 🔄 INTERCEPTOR DE REORDER: Recomputa os índices e ativa o novo topo
  Future<void> handlePlansReorder(int oldIndex, int newIndex) async {
    // Preserva o estado atual em memória local e atualiza a viewport instantaneamente
    final previousState = _planDeck.value;

    try {
      final fullyUpdatedList = await _service.processPlansReorder(
        currentList: _planDeck.value,
        oldIndex: oldIndex,
        newIndex: newIndex,
      );
      _planDeck.value = fullyUpdatedList;
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Reorder processing failed. Restoring rollback state.');
      _planDeck.value = previousState;
    }
  }

  /// 📦 PROTOCOLO ARCHIVE (Swipe Esquerda -> Direita)
  Future<void> archivePlan(String id) async {
    try {
      await _service.archiveSalaryPlan(id);
      _removePlanFromViewport(id);
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Archive operation fail -> $e');
      loadFirebasePlans();
    }
  }

  /// 🗑️ PROTOCOLO PURGE PERMANENTE (Swipe Direita -> Esquerda)
  Future<void> purgePlan(String id) async {
    try {
      await _service.purgeSalaryPlan(id);
      _removePlanFromViewport(id);
    } catch (e) {
      debugPrint('DEBUG_SYSTEM [PlansManager]: Purge operation fail -> $e');
      loadFirebasePlans();
    }
  }

  void _removePlanFromViewport(String id) {
    final updatedList = List<SalaryPlan>.from(_planDeck.value);
    final index = updatedList.indexWhere((p) => p.id == id);
    if (index != -1) {
      updatedList.removeAt(index);

      // Recalcula o sequenciamento numérico restante para não deixar buracos no sort_order
      final List<SalaryPlan> sequentialList = [];
      for (int i = 0; i < updatedList.length; i++) {
        bool shouldBeActive = updatedList[i].isActive;
        if (i == 0) shouldBeActive = true; // Se o topo antigo sumiu, o próximo assume

        sequentialList.add(updatedList[i].copyWith(sortOrder: i, isActive: shouldBeActive));
      }
      _planDeck.value = sequentialList;
    }
  }

  /// 🚨 DIALOG TERMINAL CONFIRM
  Future<bool?> showTerminalConfirmDialog(String planName, BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: StackMoneyTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: const BorderSide(color: StackMoneyTheme.magentaNeon, width: 0.5),
          ),
          title: const Text('[SYSTEM_WARNING]', style: TextStyle(fontFamily: 'Orbitron', color: StackMoneyTheme.magentaNeon, fontSize: 14)),
          content: Text(
            'EXECUTE PURGE PROTOCOL ON SALARY PLAN:\n"${planName.toUpperCase()}"?\n\nALL FORECAST ALIGNMENTS WILL BE EXPURGED.',
            style: const TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.platinumSilver, fontSize: 11, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('[CANCEL]', style: TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 12)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('[PURGE_DATA]', style: TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.magentaNeon, fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}