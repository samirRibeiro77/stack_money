import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/data/repository/firebase_plan_repository.dart';

class PlanManagementService {
  final FirebasePlanRepository _repository = FirebasePlanRepository();

  /// Obtém a listagem limpa de planos ativos ordenada por posição
  Future<List<SalaryPlan>> getActiveSalaryPlans() async {
    return await _repository.fetchActivePlans();
  }

  /// Salva ou modifica a folha de estrutura de um plano individual
  Future<void> saveSalaryPlan(SalaryPlan plan) async {
    await _repository.savePlan(plan);
  }

  /// Modifica o estado lógico para arquivado
  Future<void> archiveSalaryPlan(String id) async {
    await _repository.archivePlan(id);
  }

  /// Executa o expurgo físico do plano no banco
  Future<void> purgeSalaryPlan(String id) async {
    await _repository.purgePlan(id);
  }

  /// 🔄 INTERCEPTOR MESTRE DE ARRRASTO (Reorderable Engine)
  /// Trata a matemática da lista ao arrastar e aplica a ativação automática caso o topo mude
  Future<List<SalaryPlan>> processPlansReorder({
    required List<SalaryPlan> currentList,
    required int oldIndex,
    required int newIndex,
  }) async {
    final List<SalaryPlan> workingList = List<SalaryPlan>.from(currentList);

    // Ajuste padrão do ponteiro de index do ReorderableListView do Flutter
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Move o item fisicamente de slot no array local
    final SalaryPlan movedPlan = workingList.removeAt(oldIndex);
    workingList.insert(newIndex, movedPlan);

    // 🔥 RECALCULA O REORDER SEQUENCIAL E CORRIGE AS REGRA DE ATIVAÇÃO
    final List<SalaryPlan> fullyUpdatedList = [];

    for (int i = 0; i < workingList.length; i++) {
      final currentPlan = workingList[i];

      bool nextActiveState = currentPlan.isActive;

      // Se caiu na Posição 0 (Topo), vira o plano ativo automaticamente
      if (i == 0) {
        nextActiveState = true;
      } else {
        // Se foi empurrado para baixo do topo, perde o estado de ativo
        nextActiveState = false;
      }

      // Clona injetando os novos metadados estáveis de sortOrder e ativação única
      fullyUpdatedList.add(
        currentPlan.copyWith(
          sortOrder: i,
          isActive: nextActiveState,
        ),
      );
    }

    // Dispara o disparo atômico em lote (Batch) em background no Cloud Firestore
    // para a UI destravar na hora sem lag visual no arrasto do dedo!
    _repository.updatePlansOrderInBatch(fullyUpdatedList).catchError((err) {
      print('❌ [FIRESTORE_FAIL] -> Background reorder batch sync failed: $err');
    });

    return fullyUpdatedList;
  }
}