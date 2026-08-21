import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/enum/plan_edit_actions.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/manager/plan_edit_manager.dart';
import 'package:stack_money/features/plan_edit/widgets/distribution/distribution_section.dart';
import 'package:stack_money/features/plan_edit/widgets/editable_title.dart';
import 'package:stack_money/features/plan_edit/widgets/inflow/inflow_section.dart';
import 'package:stack_money/features/plan_edit/widgets/net_salary/net_salary_sticky_hud.dart';
import 'package:stack_money/features/plan_edit/widgets/outflow/outflow_section.dart';

import '../../core/constants/app_sizes.dart' show AppSizes;

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
    _manager = PlanEditManager(widget.plan, context);
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  Future<bool> _showUnsavedChangesDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    if (!_manager.isDirty) {
      return true;
    }

    final qty = _manager.pendingChangesCount(l10n);
    final diffNote = _manager.getDiffNote(l10n);
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SmDialog(
        title: l10n.planChangedTitle,
        message: l10n.planChangedMessage(qty),
        content: _manager.currentPlan.name,
        note: diffNote,
        color: StackMoneyTheme.cyanNeon,
        onConfirm: () async {
          final success = await _manager.savePlan();
          if (dialogContext.mounted) {
            dialogContext.pop(success);
          }
        },
        onCancel: () {
          dialogContext.pop(false);
        },
        onDeny: () {
          dialogContext.pop(true);
        },
      ),
    );

    return shouldLeave ?? false;
  }

  String _chipLabel(
    AppLocalizations l10n, {
    bool isActive = false,
    bool isPreview = false,
  }) {
    if (isPreview) {
      return l10n.preview;
    }

    if (isActive) {
      return l10n.active;
    }

    return l10n.setActive;
  }

  Color _chipColor({bool isActive = false, bool isPreview = false}) {
    if (isPreview) {
      return StackMoneyTheme.magentaNeon;
    }

    if (isActive) {
      return StackMoneyTheme.cyanNeon;
    }

    return StackMoneyTheme.mutedGrey;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final shouldPop = await _showUnsavedChangesDialog(context);
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: ValueListenableBuilder<SalaryPlan>(
        valueListenable: _manager.planNotifier,
        builder: (_, currentPlan, _) {
          return Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: AppSizes.x10,
                ),
                onPressed: () async {
                  final canLeave = await _showUnsavedChangesDialog(context);
                  if (canLeave && context.mounted) {
                    context.pop();
                  }
                },
              ),
              title: IgnorePointer(
                ignoring: currentPlan.blockEdit,
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
                  _chipLabel(
                    l10n,
                    isPreview: currentPlan.isPreview,
                    isActive: currentPlan.isActive,
                  ),
                  color: _chipColor(
                    isPreview: currentPlan.isPreview,
                    isActive: currentPlan.isActive,
                  ),
                  onTap: currentPlan.isPreview
                      ? null
                      : () async => await _manager.togglePlanActivation(),
                ),

                if (!currentPlan.isPreview)...[
                  PopupMenuButton<PlanEditActions>(
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      color: StackMoneyTheme.mutedGrey,
                    ),
                    color: StackMoneyTheme.carbonGrey,
                    onSelected: (value) {
                      switch (value) {
                        case PlanEditActions.copy:
                          _manager.copyPlan();
                          break;
                        case PlanEditActions.share:
                          _manager.sharePlan();
                          break;
                        case PlanEditActions.archive:
                          _manager.archivePlan();
                          break;
                        case PlanEditActions.delete:
                          _manager.deletePlan();
                          break;
                      }
                    },
                    itemBuilder: (context) =>
                        PlanEditActions.values.map((action) {
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
                  )
                ] else...[
                  SizedBox(width: AppSizes.sizedBoxMedium)
                ]
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
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSizes.x10),
                  ),

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
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSizes.x10),
                  ),

                  /// Net Salary Buffer Section
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: NetSalaryStickyHud(plan: currentPlan),
                  ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: AppSizes.x10),
                  ),

                  /// Distribution Section
                  SliverToBoxAdapter(
                    child: DistributionSection(
                      plan: currentPlan,
                      onAddSlot: _manager.initializeNewDistributionSlot,
                      onUpdate: _manager.updateDistribution,
                      confirmDismiss: _manager.removeDistributionConfirmation,
                      onRemove: _manager.removeDistribution,
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
      ),
    );
  }
}
