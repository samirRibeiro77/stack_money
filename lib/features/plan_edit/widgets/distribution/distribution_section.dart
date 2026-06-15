import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/allocation_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class DistributionSection extends StatelessWidget {
  final SalaryPlan plan;
  final VoidCallback onAddSlot;
  final Function(
    int index, {
    String? cat,
    String? sub,
    AllocationType? type,
    double? value,
    int? targetDay,
  })
  onUpdate;
  final Function(String id) onRemove;

  const DistributionSection({
    required this.plan,
    required this.onAddSlot,
    required this.onUpdate,
    required this.onRemove,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final availableDays = plan.inflows
        .where((e) => e.value > 0)
        .map((e) => e.day)
        .toSet()
        .toList();

    final Color techColor = plan.isOverflowed
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return Column(
      children: [
        ...List.generate(plan.distributions.length, (index) {
          final row = plan.distributions[index];
          final double computedValue = plan.calculateRowAbsoluteValue(row);

          // 🔥 PONTO 1: Dismissible acoplado eliminando o botão de lixeira lateral
          return Dismissible(
            key: Key('rule_${row.id}'),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => onRemove(row.id),
            background: Container(
              margin: const EdgeInsets.symmetric(vertical: 4.0),
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.centerRight,
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: StackMoneyTheme.magentaNeon,
                size: 24,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),

              // BUG FIX 2: O container do card e seus inputs usam a ValueKey baseada na identidade real da rule
              child: StackMoneyCard(
                key: ValueKey(row.id),
                shadowColor: techColor,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: row.category,
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 12,
                            ),
                            decoration: _buildInputDecoration('CATEGORY'),
                            onChanged: (val) => onUpdate(index, cat: val),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            initialValue: row.subCategory,
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 12,
                            ),
                            decoration: _buildInputDecoration('SUBCATEGORY'),
                            onChanged: (val) => onUpdate(index, sub: val),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          flex: 3,
                          child: DropdownButtonFormField<AllocationType>(
                            initialValue: row.type,
                            isDense: true,
                            decoration: _buildInputDecoration('RULE_TYPE'),
                            dropdownColor: StackMoneyTheme.surface,
                            items: const [
                              DropdownMenuItem(
                                value: AllocationType.fixed,
                                child: Text(
                                  'R\$ FIXED',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              DropdownMenuItem(
                                value: AllocationType.percentageNet,
                                child: Text(
                                  '% OF NET',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                              DropdownMenuItem(
                                value: AllocationType.percentageGross,
                                child: Text(
                                  '% OF GROSS',
                                  style: TextStyle(fontSize: 11),
                                ),
                              ),
                            ],
                            onChanged: (val) =>
                                onUpdate(index, type: val, value: 0.0),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            key: ValueKey('${row.id}_nested_${row.type.name}'),
                            initialValue: row.value > 0
                                ? (row.type == AllocationType.fixed
                                      ? StackMoneyString.formatMoney(row.value)
                                      : row.value.toString())
                                : '',
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 12,
                            ),
                            decoration: _buildInputDecoration(
                              row.type == AllocationType.fixed
                                  ? 'VALUE'
                                  : 'FACTOR (%)',
                            ),
                            inputFormatters: row.type == AllocationType.fixed
                                ? [MoneyInputFormatter()]
                                : [],
                            onChanged: (val) {
                              double valueToSave;

                              if (row.type == AllocationType.fixed) {
                                valueToSave = StackMoneyNumber.parseMoneyStringToDouble(val);
                              } else {
                                valueToSave = StackMoneyNumber.parsePercentageStringToDouble(val);
                              }

                              onUpdate(index, value: valueToSave);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          height: 38,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                          ),
                          child: Row(
                            children: availableDays.map((d) {
                              final bool isSelected = row.targetDay == d;
                              return GestureDetector(
                                onTap: () => onUpdate(index, targetDay: d),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? techColor.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'D$d',
                                    style: TextStyle(
                                      fontFamily: 'WithValues',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? techColor
                                          : StackMoneyTheme.mutedGrey,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    if (row.type != AllocationType.fixed) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'CONVERTED: ${StackMoneyString.formatMoney(computedValue)}',
                            style: const TextStyle(
                              fontFamily: 'JetBrainsMono',
                              color: StackMoneyTheme.mutedGrey,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: AppSizes.x4),
        CardInitializeSlot('ADD_DISTRIBUTION_RULE', onTap: onAddSlot),
      ],
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontFamily: 'JetBrainsMono',
        color: StackMoneyTheme.mutedGrey,
        fontSize: 9,
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: StackMoneyTheme.cyanNeon, width: 1),
      ),
    );
  }
}
