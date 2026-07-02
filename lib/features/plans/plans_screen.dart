import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_reorderable_list.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plans/manager/plans_manager.dart';
import 'package:stack_money/features/plans/widgets/dismissible_plan_card.dart';
import 'package:stack_money/features/plans/widgets/plan_list_card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({super.key = const ValueKey(route)});

  static const route = '/plans';

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  final _manager = PlansManager();

  Future<bool?> _confirmDismiss(
    DismissDirection direction,
    SalaryPlan plan,
  ) async {
    if (direction == DismissDirection.endToStart) {
      return await _manager.showTerminalConfirmDialog(plan.name, context);
    } else {
      _manager.archivePlan(plan.id, plan.isArchived);
      return false;
    }
  }

  void _purgePlan(DismissDirection direction, String id) async {
    if (direction == DismissDirection.endToStart) {
      _manager.purgePlan(id);
    }
  }

  @override
  void initState() {
    super.initState();
    _manager.loadFirebasePlans();
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
    return ValueListenableBuilder<bool>(
      valueListenable: _manager.showArchivedNotifier,
      builder: (context, showArchived, child) {
        final baseList = planList
            .where((p) => showArchived ? true : !p.isArchived)
            .toList();

        final activePlan = baseList.where((p) => p.isActive).firstOrNull;
        final inactivePlans = baseList.where((p) => !p.isActive).toList();

        inactivePlans.sort((a, b) {
          if (a.position != b.position) {
            return a.position.compareTo(b.position);
          }
          return b.createdAt.compareTo(a.createdAt);
        });

        return SingleChildScrollView(
          child: Column(
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
              const SizedBox(height: AppSizes.sizedBoxMedium),

              CardInitializeSlot(
                l10n.newPlan,
                onTap: () => _manager.initializeNewPlanSlot(context),
              ),
              const SizedBox(height: AppSizes.sizedBoxSmall),

              if (activePlan != null) ...[
                DismissiblePlanCard(
                  activePlan,
                  key: ValueKey(activePlan.id),
                  onTap: () =>
                      _manager.navigateToPlanDetails(context, activePlan),
                  confirmDismiss: (direction) =>
                      _confirmDismiss(direction, activePlan),
                  onDismissed: (direction) =>
                      _purgePlan(direction, activePlan.id),
                ),
                const SizedBox(height: AppSizes.sizedBoxSmall),
              ],

              SmReorderableList<SalaryPlan>(
                items: inactivePlans,
                onReorder: (oldIdx, newIdx) => _manager.reorderFilteredPlans(
                  inactivePlans,
                  oldIdx,
                  newIdx,
                ),
                itemBuilder: (context, plan, index) => DismissiblePlanCard(
                  plan,
                  key: ValueKey(plan.id),
                  onTap: () => _manager.navigateToPlanDetails(context, plan),
                  confirmDismiss: (direction) =>
                      _confirmDismiss(direction, plan),
                  onDismissed: (direction) => _purgePlan(direction, plan.id),
                ),
                feedbackChildBuilder: (_, plan, _) =>
                    PlanListCard(plan, onTap: () {}),
                draggingChildBuilder: (_, plan, _) =>
                    PlanListCard(plan, onTap: () {}),
              ),
            ],
          ),
        );
      },
    );
  }
}
