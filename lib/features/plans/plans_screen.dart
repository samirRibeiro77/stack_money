import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
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
            return _buildPlansContent(context, planList);
          },
        );
      },
    );
  }

  Widget _buildPlansContent(BuildContext context, List<SalaryPlan> planList) {
    final l10n = AppLocalizations.of(context)!;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.showArchivedNotifier,
      builder: (_, showArchived, _) {
        /// Filter Archived
        final baseList = planList
            .where((p) => showArchived ? true : !p.isArchived)
            .toList();

        /// Active and Inactive plans
        final activePlan = baseList.where((p) => p.isActive).firstOrNull;
        final inactivePlans = baseList.where((p) => !p.isActive).toList();

        /// Order by position
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

              /// Show/Hide active plan
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

              /// Reorderable list
              Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(inactivePlans.length, (index) {
                  final plan = inactivePlans[index];

                  return DragTarget<int>(
                    onAcceptWithDetails: (details) {
                      _manager.reorderFilteredPlans(
                        inactivePlans,
                        details.data,
                        index,
                      );
                    },
                    builder: (context, candidateData, rejectedData) {
                      final bool isHovered =
                          candidateData.isNotEmpty &&
                          candidateData.first != index;

                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isHovered)
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: AppSizes.x4,
                              margin: const EdgeInsets.symmetric(
                                vertical: AppSizes.min,
                              ),
                              decoration: BoxDecoration(
                                color: StackMoneyTheme.cyanNeon.withValues(
                                  alpha: 0.25,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppSizes.radiusSmall,
                                ),
                                border: Border.all(
                                  color: StackMoneyTheme.cyanNeon.withValues(
                                    alpha: 0.4,
                                  ),
                                  width: 0.8,
                                ),
                              ),
                            ),

                          LongPressDraggable<int>(
                            data: index,
                            axis: Axis.vertical,
                            maxSimultaneousDrags: isSecureActive ? 0 : 1,
                            feedback: Material(
                              color: Colors.transparent,
                              child: Opacity(
                                opacity: 0.75,
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width -
                                      AppSizes.x16,
                                  child: PlanListCard(plan, onTap: () {}),
                                ),
                              ),
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.15,
                              child: PlanListCard(plan, onTap: () {}),
                            ),
                            child: DismissiblePlanCard(
                              plan,
                              key: ValueKey(plan.id),
                              onTap: () =>
                                  _manager.navigateToPlanDetails(context, plan),
                              confirmDismiss: (direction) =>
                                  _confirmDismiss(direction, plan),
                              onDismissed: (direction) =>
                                  _purgePlan(direction, plan.id),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
