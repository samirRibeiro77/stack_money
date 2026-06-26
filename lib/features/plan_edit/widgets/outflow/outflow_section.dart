import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/widgets/flow_title.dart';
import 'package:stack_money/features/plan_edit/widgets/outflow/outflow_section_card.dart';

class OutflowSection extends StatelessWidget {
  final SalaryPlan plan;
  final ValueListenable<bool> expandState;
  final VoidCallback toggleExpandState;
  final Function(
    int index, {
    String? name,
    DeductionType? type,
    double? value,
    int? targetDay,
  })
  onUpdate;
  final Function(int index, BuildContext ctx) onRemove;

  const OutflowSection({
    required this.plan,
    required this.expandState,
    required this.toggleExpandState,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final availableDays = plan.inflows
        .where((e) => e.value > 0)
        .map((e) => e.day)
        .toSet()
        .toList();

    return SmCard(
      removePadding: true,
      shadowColor: StackMoneyTheme.magentaNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowTitle(
            title: l10n.mandatoryDeductions,
            balance: plan.totalOutflows,
            toggleExpand: toggleExpandState,
            color: StackMoneyTheme.magentaNeon,
          ),
          ValueListenableBuilder(
            valueListenable: expandState,
            builder: (_, isExpand, _) {
              if (!isExpand) return const SizedBox.shrink();

              return Column(
                children: [
                  const Divider(color: StackMoneyTheme.background, height: 1),

                  Padding(
                    padding: EdgeInsets.all(AppSizes.x8),
                    child: Column(
                      children: List.generate(plan.outflows.length, (index) {
                        final row = plan.outflows[index];
                        final isLast = index == plan.outflows.length - 1;
                        final double absVal = plan.calculateOutflowAbsolute(
                          row,
                        );

                        return OutflowSectionCard(
                          row: row,
                          index: index,
                          availableDays: availableDays,
                          isLast: isLast,
                          absVal: absVal,
                          onUpdate: onUpdate,
                          onRemove: onRemove,
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
