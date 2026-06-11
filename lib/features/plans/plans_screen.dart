import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plans/manager/plans_manager.dart';
import 'package:stack_money/features/plans/widgets/plan_list_card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key = const ValueKey(route)});

  static const route = '/plans';

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _manager = PlansManager();

  @override
  void initState() {
    super.initState();
    _manager.loadFirebasePlans();
  }

  void _navigateToDetails(SalaryPlan plan) {
    // 🛸 Encaminha para a tela fullscreen futura de edição (Create/Edit Plan Screen)
    debugPrint(
      '🛸 [NAVIGATION] -> Routing to target fullscreen editor for: ${plan.id}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.isLoading,
      builder: (_, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: StackMoneyTheme.cyanNeon,
              backgroundColor: StackMoneyTheme.surface,
            ),
          );
        }

        return ValueListenableBuilder<List<SalaryPlan>>(
          valueListenable: _manager.planDeckNotifier,
          builder: (context, planList, child) {
            return _buildPlansContent(l10n, planList);
          },
        );
      },
    );
  }

  Widget _buildPlansContent(AppLocalizations l10n, List<SalaryPlan> planList) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    // Separando de forma limpa o card ativo de liderança dos remanescentes legados
    final SalaryPlan? activePlan =
        planList.isNotEmpty && planList.first.isActive ? planList.first : null;
    final List<SalaryPlan> legacyPlans = activePlan != null
        ? planList.sublist(1)
        : planList;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpandableHeader(
          title: 'Add new plan',
          validation: ValueNotifier(true),
          toggle: () => print('FILTER_TRIGGER'),
          activeIcon: Icons.archive_outlined,
          inactiveIcon: Icons.unarchive_outlined,
          activeColor: StackMoneyTheme.magentaNeon,
          inactiveColor: StackMoneyTheme.cyanNeon,
        ),
        const SizedBox(height: AppSizes.x12),

        // 👑 SLOT 1: Exibe isolado o plano que está ativo no comando operacional
        if (activePlan != null)
          _buildDismissibleWrapper(activePlan, isSecureActive),

        // ➕ SLOT 2: O card tracejado nativo fixado logo abaixo do líder da fila
        CardInitializeSlot(
          l10n.newBucket,
          // Reaproveita ou consome a tag l10n equivalente a "NEW_PLAN"
          onTap: _manager.initializeNewPlanSlot,
        ),
        const SizedBox(height: AppSizes.x4),

        // 🔋 DECK DE ARRASTO MANUAL (Apenas para os cards legados remanescentes)
        if (legacyPlans.isNotEmpty)
          SizedBox(
            // Limita o tamanho ou deixa crescer dinamicamente baseado na árvore
            child: ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // Scroll orquestrado pela Sliver externa principal
              itemCount: legacyPlans.length,

              // 🔥 RESPOSTA A: Se a segurança estiver ativada (valores ocultos), TRAVA COMPLETAMENTE o drag and drop
              buildDefaultDragHandles: !isSecureActive,

              onReorder: (oldIdx, newIdx) {
                // Como a lista que passamos para o builder é a sublist (sem o ativo),
                // reajustamos os índices adicionando +1 para refletir a posição real do deck mestre no manager
                _manager.handlePlansReorder(oldIdx + 1, newIdx + 1);
              },
              itemBuilder: (context, index) {
                final plan = legacyPlans[index];
                return Container(
                  key: ValueKey(plan.id),
                  // 🔥 SUGESTÃO ANTERIOR: UUID estável como ValueKey
                  child: _buildDismissibleWrapper(plan, isSecureActive),
                );
              },
            ),
          ),
      ],
    );
  }

  /// Constrói o envelopamento bidirecional Dismissible com travas de segurança biométrica
  Widget _buildDismissibleWrapper(SalaryPlan plan, bool isSecureActive) {
    return Dismissible(
      key: Key('dismiss_${plan.id}'),

      // 🔥 RESPOSTA A: Se o modo seguro estiver ligado, congela as direções e impede o swipe
      direction: isSecureActive
          ? DismissDirection.none
          : DismissDirection.horizontal,

      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Direita para Esquerda -> Purge Permanente
          return await _manager.showTerminalConfirmDialog(plan.name, context);
        } else {
          // Esquerda para Direita -> Arquivamento Lógico direto sem Dialog
          return true;
        }
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          _manager.purgePlan(plan.id);
        } else {
          _manager.archivePlan(plan.id);
        }
      },

      // 📦 BACKGROUND 1: Arrastar da Esquerda -> Direita revela Arquivamento (MutedGrey)
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: StackMoneyTheme.mutedGrey.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.mutedGrey.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: const Icon(
          Icons.archive_rounded,
          color: StackMoneyTheme.mutedGrey,
          size: 24,
        ),
      ),

      // 🗑️ BACKGROUND 2: Arrastar da Direita -> Esquerda revela Purge (Magenta)
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: StackMoneyTheme.magentaNeon.withOpacity(0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_forever_rounded,
          color: StackMoneyTheme.magentaNeon,
          size: 24,
        ),
      ),

      child: PlanListCard(plan: plan, onTap: () => _navigateToDetails(plan)),
    );
  }
}
