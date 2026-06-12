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

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.showArchivedNotifier,
      builder: (context, showArchived, child) {
        final filteredList = planList
            .where((p) => showArchived ? true : !p.isArchived)
            .toList();

        filteredList.sort((a, b) {
          if (a.isActive && !b.isActive) return -1;
          if (!a.isActive && b.isActive) return 1;
          return b.createdAt.compareTo(a.createdAt);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExpandableHeader(
              title: l10n.plansConfig,
              validation: _manager.showArchivedNotifier,
              toggle: _manager.toggleShowArchived,
              activeIcon: Icons.archive_outlined,
              inactiveIcon: Icons.unarchive_outlined,
              activeColor: StackMoneyTheme.magentaNeon,
              inactiveColor: StackMoneyTheme.cyanNeon,
            ),
            const SizedBox(height: AppSizes.x12),

            CardInitializeSlot(
              l10n.newPlan,
              onTap: _manager.initializeNewPlanSlot,
            ),
            const SizedBox(height: AppSizes.x4),

            ...List.generate(filteredList.length, (index) {
              final plan = filteredList[index];
              return _buildDismissibleWrapper(plan, isSecureActive);
            }),
          ],
        );
      },
    );
  }

  Widget _buildDismissibleWrapper(SalaryPlan plan, bool isSecureActive) {
    return Dismissible(
      key: Key('dismiss_${plan.id}'),
      direction: isSecureActive
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Direita para Esquerda -> Purge abre modal de confirmação
          return await _manager.showTerminalConfirmDialog(plan.name, context);
        } else {
          // 🔥 SACADA MESTRE: Trata o arquivamento aqui dentro de forma síncrona e retorna false!
          // Isso impede o widget de sumir violentamente, deixando o ValueNotifier atualizar a UI de forma ultra limpa.
          _manager.archivePlan(plan.id, plan.isArchived);
          return false;
        }
      },
      onDismissed: (direction) {
        // Apenas o Purge executa no onDismissed real, pois ele de fato ranca o item do array mestre
        if (direction == DismissDirection.endToStart) {
          _manager.purgePlan(plan.id);
        }
      },
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: plan.isArchived
              ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.12)
              : StackMoneyTheme.mutedGrey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: plan.isArchived
                ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.3)
                : StackMoneyTheme.mutedGrey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Icon(
          plan.isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
          color: plan.isArchived
              ? StackMoneyTheme.cyanNeon
              : StackMoneyTheme.mutedGrey,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.3),
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
