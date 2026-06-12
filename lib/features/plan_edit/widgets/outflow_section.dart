import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/deduction_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class OutflowSection extends StatelessWidget {
  final SalaryPlan plan;
  final Function(int index, {String? name, DeductionType? type, double? value, int? targetDay}) onUpdate;
  final Function(int index) onRemove;

  const OutflowSection({
    required this.plan,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final availableDays = plan.inflows.where((e) => e.value > 0).map((e) => e.day).toSet().toList();
    if (!availableDays.contains(0)) availableDays.add(0);

    return StackMoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MANDATORY_DEDUCTIONS', style: textTheme.titleSmall),
              Text(
                StackMoneyString.formatMoney(doubleValue: plan.totalOutflows),
                style: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.magentaNeon, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.x4),
          const Divider(color: Colors.white10),

          ...List.generate(plan.outflows.length, (index) {
            final row = plan.outflows[index];
            final isLast = index == plan.outflows.length - 1;
            final double absVal = plan.calculateOutflowAbsolute(row);

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.01),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withOpacity(0.03))
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          initialValue: row.name,
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
                          decoration: _buildInputDecoration('DEDUCTION_NAME'),
                          onChanged: (val) => onUpdate(index, name: val),
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<int>(
                          value: availableDays.contains(row.targetDay) ? row.targetDay : availableDays.first,
                          isDense: true,
                          decoration: _buildInputDecoration('TARGET'),
                          dropdownColor: StackMoneyTheme.surface,
                          items: availableDays.map((d) {
                            return DropdownMenuItem(value: d, child: Text(d == 0 ? 'N/A' : 'D$d', style: const TextStyle(fontSize: 11)));
                          }).toList(),
                          onChanged: (val) => onUpdate(index, targetDay: val),
                        ),
                      ),
                      if (!isLast)
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: StackMoneyTheme.magentaNeon, size: 18),
                          onPressed: () => onRemove(index),
                        )
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<DeductionType>(
                          value: row.type,
                          isDense: true,
                          decoration: _buildInputDecoration('RULE_TYPE'),
                          dropdownColor: StackMoneyTheme.surface,
                          items: const [
                            DropdownMenuItem(value: DeductionType.fixed, child: Text('R\$ FIXED', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: DeductionType.percentageGross, child: Text('% OF GROSS', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (val) => onUpdate(index, type: val, value: 0.0),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('${row.id}_${row.type.name}'),
                          initialValue: row.value > 0 ? (row.type == DeductionType.fixed ? StackMoneyString.formatMoney(doubleValue: row.value) : row.value.toStringAsFixed(0)) : '',
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
                          decoration: _buildInputDecoration(row.type == DeductionType.fixed ? 'VAL (R\)' : 'FACTOR (%)'),
                          inputFormatters: row.type == DeductionType.fixed ? [MoneyInputFormatter()] : [],
                          onChanged: (val) {
                            double parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                            if (row.type == DeductionType.fixed) parsed /= 100.0;
                            onUpdate(index, value: parsed);
                          },
                        ),
                      ),
                    ],
                  ),
                  if (row.type == DeductionType.percentageGross && row.value > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('DEDUCTED: ${StackMoneyString.formatMoney(doubleValue: absVal)}', style: const TextStyle(fontSize: 9, color: StackMoneyTheme.magentaNeon, fontFamily: 'JetBrainsMono')),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 9),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.white.withOpacity(0.06))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: StackMoneyTheme.cyanNeon, width: 1)),
    );
  }
}