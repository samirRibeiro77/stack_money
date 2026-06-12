import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/inflow_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class InflowSection extends StatelessWidget {
  final SalaryPlan plan;
  final Function(double val) onBaseUpdate;
  final Function(int index, {InflowType? type, double? value, int? day}) onUpdate;
  final Function(int index) onRemove;

  const InflowSection({
    required this.plan,
    required this.onBaseUpdate,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StackMoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('GROSS_REVENUE_STREAM', style: textTheme.titleSmall),
              Text(
                StackMoneyString.formatMoney(doubleValue: plan.totalGrossSalary),
                style: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.cyanNeon, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.x6),

          // 🔥 Campo Base Salary Mestre do Split
          TextFormField(
            initialValue: plan.baseSalary > 0 ? StackMoneyString.formatMoney(doubleValue: plan.baseSalary) : '',
            keyboardType: TextInputType.number,
            style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13, fontWeight: FontWeight.bold),
            decoration: _buildInputDecoration('BASE_GROSS_SALARY (R\$)'),
            inputFormatters: [MoneyInputFormatter()],
            onChanged: (val) {
              final double parsed = (double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0) / 100.0;
              onBaseUpdate(parsed);
            },
          ),
          const SizedBox(height: AppSizes.x6),
          const Divider(color: Colors.white10),

          ...List.generate(plan.inflows.length, (index) {
            final row = plan.inflows[index];
            final isLast = index == plan.inflows.length - 1;
            final double absVal = plan.calculateInflowAbsolute(row);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Dropdown de escolha entre % e R$ Fixo
                      SizedBox(
                        width: 105,
                        child: DropdownButtonFormField<InflowType>(
                          value: row.type,
                          isDense: true,
                          decoration: _buildInputDecoration('TYPE'),
                          dropdownColor: StackMoneyTheme.surface,
                          items: const [
                            DropdownMenuItem(value: InflowType.percentageBase, child: Text('% BASE', style: TextStyle(fontSize: 11))),
                            DropdownMenuItem(value: InflowType.fixed, child: Text('R\$ FIX', style: TextStyle(fontSize: 11))),
                          ],
                          onChanged: (val) => onUpdate(index, type: val, value: 0.0),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Input numérico inteligente (Aceita % puro ou R$ formatado)
                      Expanded(
                        child: TextFormField(
                          key: ValueKey('${row.id}_${row.type.name}'),
                          initialValue: row.value > 0
                              ? (row.type == InflowType.fixed ? StackMoneyString.formatMoney(doubleValue: row.value) : row.value.toStringAsFixed(0))
                              : '',
                          keyboardType: TextInputType.number,
                          style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
                          decoration: _buildInputDecoration(row.type == InflowType.fixed ? 'VAL (R\)' : 'FACTOR (%)'),
                          inputFormatters: row.type == InflowType.fixed ? [MoneyInputFormatter()] : [],
                          onChanged: (val) {
                            double parsed = double.tryParse(val.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0.0;
                            if (row.type == InflowType.fixed) parsed /= 100.0;
                            onUpdate(index, value: parsed);
                          },
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Escolha do Dia (Range 0 a 31)
                      SizedBox(
                        width: 80,
                        child: DropdownButtonFormField<int>(
                          value: row.day.clamp(0, 31),
                          isDense: true,
                          decoration: _buildInputDecoration('DAY'),
                          dropdownColor: StackMoneyTheme.surface,
                          items: List.generate(32, (i) => i).map((d) {
                            return DropdownMenuItem(
                              value: d,
                              child: Text(d == 0 ? 'N/A' : '$d', style: const TextStyle(fontSize: 11)),
                            );
                          }).toList(),
                          onChanged: (val) => onUpdate(index, day: val),
                        ),
                      ),

                      if (!isLast) ...[
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: StackMoneyTheme.magentaNeon, size: 20),
                          onPressed: () => onRemove(index),
                        ),
                      ]
                    ],
                  ),
                  if (row.type == InflowType.percentageBase && row.value > 0)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text('CONVERTED: ${StackMoneyString.formatMoney(doubleValue: absVal)}', style: const TextStyle(fontSize: 9, color: StackMoneyTheme.mutedGrey, fontFamily: 'JetBrainsMono')),
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