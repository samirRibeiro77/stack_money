import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/plan_status.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/manager/plan_edit_manager.dart';
import 'package:stack_money/features/plan_edit/widgets/editable_title.dart';
import 'package:stack_money/features/plan_edit/widgets/inflow/inflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/outflow/outflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/net_salary/net_salary_sticky_hud.dart';
import 'package:stack_money/features/plan_edit/widgets/distribution/distribution_section.dart';

class PlanEditScreen extends StatefulWidget {
  final SalaryPlan plan;

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

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: AppSizes.x10,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: EditableTitle(
          _manager.currentPlan.name,
          onSave: (newName) => _manager.updatePlanName(newName),
        ),
        centerTitle: false,
        backgroundColor: StackMoneyTheme.background,
        surfaceTintColor: StackMoneyTheme.carbonGrey,
        actions: [
          ValueListenableBuilder<SalaryPlan>(
            valueListenable: _manager.planNotifier,
            builder: (context, currentPlan, _) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSizes.x8),
                child: PlanStatus(
                  currentPlan.isActive ? l10n.activePlan : l10n.setActive,
                  color: currentPlan.isActive
                      ? StackMoneyTheme.cyanNeon
                      : StackMoneyTheme.mutedGrey,
                  onTap: currentPlan.isActive
                      ? null
                      : () async => await _manager.triggerPlanActivation(),
                ),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<SalaryPlan>(
        valueListenable: _manager.planNotifier,
        builder: (_, currentPlan, _) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSizes.x8),
            child: CustomScrollView(
              controller: _manager.scrollController,
              clipBehavior: Clip.none,
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x8)),

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

                /// Net Salary Buffer Section
                SliverPersistentHeader(
                  pinned: true,
                  delegate: NetSalaryStickyHud(plan: currentPlan),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.x10)),

                /// Distribution Section
                SliverToBoxAdapter(
                  child: DistributionSection(
                    plan: currentPlan,
                    onAddSlot: _manager.initializeNewDistributionSlot,
                    onUpdate: _manager.updateDistribution,
                    onRemove: _manager.removeDistribution,
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: AppSizes.navBarPaddingBottom),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
