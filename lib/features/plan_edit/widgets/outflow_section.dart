import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class OutflowSection extends StatelessWidget {
  final SalaryPlan plan;
  final VoidCallback onAdd;
  final Function(int index, {String? name, double? value, int? targetDay}) onUpdate;
  final Function(int index) onRemove;

  const OutflowSection({
    required this.plan,
    required this.onAdd,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    // Captura os dias preenchidos nas receitas (remove duplicados e zeros)
    final availableDays = plan.inflows.where((e) => e.value > 0).map((e) => e.day).toSet().toList();
    if (availableDays.isEmpty) availableDays.add(5);

    return StackMoneyCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MANDATORY_DEDUCTIONS', style: textTheme.titleSmall),
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, color: StackMoneyTheme.cyanNeon, size: 22),
                onPressed: onAdd,
              ),
            ],
          ),
          const SizedBox(height: AppSizes.x4),
          const Divider(color: Colors.white10),
          const SizedBox(height: AppSizes.x4),

          if (plan.outflows.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Center(child: Text('[ NO_DEDUCTIONS_REGISTERED ]', style: TextStyle(fontFamily: 'JetBrainsMono', color: StackMoneyTheme.mutedGrey, fontSize: 11))),
            ),

          ...List.generate(plan.outflows.length, (index) {
            final row = plan.outflows[index];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                children: [
                  // Input Nome da Dedução
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: row.name,
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
                      decoration: _buildInputDecoration('DEDUCTION'),
                      onChanged: (val) => onUpdate(index, name: val),
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Input Valor
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      initialValue: row.value > 0 ? StackMoneyString.formatMoney(doubleValue: row.value) : '',
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12),
                      decoration: _buildInputDecoration('VAL (R\$)'),
                      inputFormatters: [PureDigitCurrencyFormatter()],
                      onChanged: (val) {
                        final raw = val.replaceAll(RegExp(r'[^0-9]'), '');
                        final double parsed = (double.tryParse(raw) ?? 0.0) / 100.0;
                        onUpdate(index, value: parsed);
                      },
                    ),
                  ),
                  const SizedBox(width: 6),

                  // Dropdown de ancoragem de dia (Lê apenas datas válidas de receita)
                  SizedBox(
                    width: 68,
                    child: DropdownButtonFormField<int>(
                      value: availableDays.contains(row.targetDay) ? row.targetDay : availableDays.first,
                      isDense: true,
                      decoration: _buildInputDecoration('IN_DAY'),
                      dropdownColor: StackMoneyTheme.surface,
                      items: availableDays.map((d) {
                        return DropdownMenuItem(
                          value: d,
                          child: Text('$d', style: const TextStyle(fontSize: 12, fontFamily: 'JetBrainsMono')),
                        );
                      }).toList(),
                      onChanged: (val) => onUpdate(index, targetDay: val),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: StackMoneyTheme.magentaNeon, size: 18),
                    onPressed: () => onRemove(index),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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