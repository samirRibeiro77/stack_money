import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/plan_edit_actions.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/manager/plan_edit_manager.dart';
import 'package:stack_money/features/plan_edit/widgets/editable_title.dart';
import 'package:stack_money/features/plan_edit/widgets/inflow/inflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/outflow/outflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/net_salary/net_salary_sticky_hud.dart';
import 'package:stack_money/features/plan_edit/widgets/distribution/distribution_section.dart';

class PlanEditScreen extends StatefulWidget {
  final SalaryPlan plan;

  static const route = '/plan_edit';

  const PlanEditScreen({required this.plan, super.key});

  @override
  State<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends State<PlanEditScreen> {
  late final PlanEditManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = PlanEditManager(widget.plan);
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<SalaryPlan>(
      valueListenable: _manager.planNotifier,
      builder: (context, currentPlan, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: AppSizes.x10,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: IgnorePointer(
              ignoring: currentPlan.isActive,
              child: EditableTitle(
                currentPlan.name,
                onSave: (newName) => _manager.updatePlanName(newName),
              ),
            ),
            centerTitle: false,
            backgroundColor: StackMoneyTheme.background,
            surfaceTintColor: StackMoneyTheme.carbonGrey,
            actions: [
              SmChipButton(
                currentPlan.isActive ? l10n.activePlan : l10n.setActive,
                color: currentPlan.isActive
                    ? StackMoneyTheme.cyanNeon
                    : StackMoneyTheme.mutedGrey,
                onTap: () async => await _manager.togglePlanActivation(),
              ),

              PopupMenuButton<PlanEditActions>(
                enabled: !currentPlan.isActive,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: StackMoneyTheme.mutedGrey,
                ),
                color: StackMoneyTheme.carbonGrey,
                onSelected: (value) {
                  switch (value) {
                    case PlanEditActions.archive:
                      _manager.archivePlan(context);
                      break;
                    case PlanEditActions.delete:
                      _manager.deletePlan(context);
                      break;
                    case PlanEditActions.copy:
                      _manager.copyPlan(context);
                      break;
                  }
                },
                itemBuilder: (context) => PlanEditActions.values.map((action) {
                  return PopupMenuItem(
                    value: action,
                    child: Row(
                      children: [
                        Icon(action.icon, color: action.color),
                        const SizedBox(width: AppSizes.x2),
                        Text(
                          action.text(l10n),
                          style: textTheme.bodySmall?.copyWith(
                            color: action.color,
                            fontWeight: AppTypography.weightBold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSizes.x8),
            child: CustomScrollView(
              controller: _manager.scrollController,
              clipBehavior: Clip.none,
              slivers: [
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.sizedBoxLarge),
                ),

                /// Inflow Section
                SliverToBoxAdapter(
                  child: InflowSection(
                    plan: currentPlan,
                    expandState: _manager.inflowExpandState,
                    toggleExpandState: _manager.toggleInflowExpand,
                    onBaseUpdate: _manager.updateBaseSalary,
                    onUpdate: _manager.updateInflow,
                    onRemove: _manager.removeInflow,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x10)),

                /// Outflow Section
                SliverToBoxAdapter(
                  child: OutflowSection(
                    plan: currentPlan,
                    expandState: _manager.outflowExpandState,
                    toggleExpandState: _manager.toggleOutflowExpand,
                    onUpdate: _manager.updateOutflow,
                    onRemove: _manager.removeOutflow,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x10)),

                /// Net Salary Buffer Section (Mantido ativo por ser puramente visual)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: NetSalaryStickyHud(plan: currentPlan),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x10)),

                /// Distribution Section
                SliverToBoxAdapter(
                  child: IgnorePointer(
                    ignoring: currentPlan.isActive,
                    child: DistributionSection(
                      plan: currentPlan,
                      onAddSlot: _manager.initializeNewDistributionSlot,
                      onUpdate: _manager.updateDistribution,
                      confirmDismiss: _manager.removeDistributionConfirmation,
                      onRemove: _manager.removeDistribution,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.navBarPaddingBottom),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
