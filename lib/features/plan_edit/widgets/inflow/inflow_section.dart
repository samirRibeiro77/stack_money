import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/features/plan_edit/widgets/flow_title.dart';
import 'package:stack_money/features/plan_edit/widgets/inflow/inflow_section_row.dart';

class InflowSection extends StatelessWidget {
  final SalaryPlan plan;
  final Function(double val) onBaseUpdate;
  final Function(int index, {InflowType? type, double? value, int? day})
  onUpdate;
  final Function(int index) onRemove;

  InflowSection({
    required this.plan,
    required this.onBaseUpdate,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  final _expandState = ValueNotifier(false);

  void _toggleExpandState() => _expandState.value = !_expandState.value;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return StackMoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowTitle(
            title: l10n.grossRevenue,
            balance: plan.totalGrossSalary,
            toggleExpand: _toggleExpandState,
          ),
          ValueListenableBuilder(
            valueListenable: _expandState,
            builder: (_, isExpand, _) {
              if (!isExpand) return SizedBox.shrink();

              return Column(
                children: [
                  const Divider(),
                  const SizedBox(height: AppSizes.x6),
                  TextFormField(
                    initialValue: plan.baseSalary > 0
                        ? StackMoneyString.formatMoney(
                            doubleValue: plan.baseSalary,
                          )
                        : '',
                    keyboardType: TextInputType.number,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: AppTypography.weightBold,
                    ),
                    decoration: StackMoneyTheme.inputDecoration(
                      l10n.baseSalary,
                    ),
                    inputFormatters: [MoneyInputFormatter()],
                    onChanged: (val) {
                      final double parsed =
                          (double.tryParse(
                                val.replaceAll(RegExp(r'[^0-9]'), ''),
                              ) ??
                              0.0) /
                          100.0;
                      onBaseUpdate(parsed);
                    },
                  ),
                  const SizedBox(height: AppSizes.x6),

                  ...List.generate(plan.inflows.length, (index) {
                    final row = plan.inflows[index];
                    final isLast = index == plan.inflows.length - 1;
                    final double absVal = plan.calculateInflowAbsolute(row);

                    return InflowSectionRow(
                      row,
                      index: index,
                      isLast: isLast,
                      absVal: absVal,
                      onUpdate: onUpdate,
                      onRemove: onRemove,
                    );
                  }),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
