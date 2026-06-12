import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class InflowSection extends StatelessWidget {
  final SalaryPlan plan;
  final Function(int index, double value, int day) onUpdate;
  final Function(int index) onRemove;

  const InflowSection({
    required this.plan,
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
              Text('GROSS_REVENUE', style: textTheme.titleSmall),
              Text(
                StackMoneyString.formatMoney(doubleValue: plan.totalGrossSalary),
                style: textTheme.titleMedium?.copyWith(color: StackMoneyTheme.cyanNeon, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.x8),
          const Divider(color: Colors.white10),
          const SizedBox(height: AppSizes.x4),

          ...List.generate(plan.inflows.length, (index) {
            final row = plan.inflows[index];
            final isLast = index == plan.inflows.length - 1;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // Campo Dia (NumberPicker simplificado via Dropdown ou IntInput)
                  SizedBox(
                    width: 70,
                    child: DropdownButtonFormField<int>(
                      initialValue: row.day.clamp(1, 28),
                      isDense: true,
                      decoration: _buildInputDecoration('DAY'),
                      dropdownColor: StackMoneyTheme.surface,
                      items: List.generate(28, (i) => i + 1).map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text('$d', style: const TextStyle(fontSize: 12, fontFamily: 'JetBrainsMono')),
                        );
                      }).toList(),
                      onChanged: (val) => onUpdate(index, row.value, val ?? row.day),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Campo Valor Monetário
                  Expanded(
                    child: TextFormField(
                      initialValue: row.value > 0 ? StackMoneyString.formatMoney(doubleValue: row.value) : '',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
                      decoration: _buildInputDecoration('AMOUNT (R\$)'),
                      inputFormatters: [PureDigitCurrencyFormatter()],
                      onChanged: (val) {
                        final raw = val.replaceAll(RegExp(r'[^0-9]'), '');
                        final double parsed = (double.tryParse(raw) ?? 0.0) / 100.0;
                        onUpdate(index, parsed, row.day);
                      },
                    ),
                  ),

                  // Botão de Deleção (Ocultado se for a linha fantasma vazia)
                  if (!isLast) ...[
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: StackMoneyTheme.magentaNeon, size: 20),
                      onPressed: () => onRemove(index),
                    ),
                  ]
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
      labelStyle: const TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 10),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: StackMoneyTheme.cyanNeon, width: 1),
      ),
    );
  }
}