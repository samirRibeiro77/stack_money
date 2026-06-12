import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class PlanListCard extends StatelessWidget {
  final SalaryPlan plan;
  final VoidCallback onTap;

  const PlanListCard({required this.plan, required this.onTap, super.key});

  Color get shadowColor {
    if (plan.isActive) return StackMoneyTheme.cyanNeon;
    if (plan.isArchived) return StackMoneyTheme.magentaNeon;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: onTap,
        child: StackMoneyCard(
          shadowColor: shadowColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha do Topo: Nome do plano + Status Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    plan.name.toUpperCase(),
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: AppTypography.weightBold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  if (plan.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: StackMoneyTheme.cyanNeon.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: StackMoneyTheme.cyanNeon,
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        '[ ACTIVE_SYSTEM ]',
                        style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: 9,
                          color: StackMoneyTheme.cyanNeon,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppSizes.x6),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: AppSizes.x6),

              // Linha de Telemetria Financeira Básica
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'GROSS_REVENUE',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          color: StackMoneyTheme.mutedGrey,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SecurityText(
                        StackMoneyString.formatMoney(
                          doubleValue: plan.totalGrossSalary,
                        ),
                        type: SecurityType.mask,
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'JetBrainsMono',
                        ),
                        activeColor: StackMoneyTheme.platinumSilver,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'REMAINING_REST',
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          color: StackMoneyTheme.mutedGrey,
                          fontSize: 9,
                        ),
                      ),
                      const SizedBox(height: 2),
                      SecurityText(
                        StackMoneyString.formatMoney(
                          doubleValue: plan.remainingRest,
                        ),
                        type: SecurityType.mask,
                        style: textTheme.bodyMedium?.copyWith(
                          fontFamily: 'JetBrainsMono',
                          fontWeight: FontWeight.bold,
                        ),
                        activeColor: plan.isOverflowed
                            ? StackMoneyTheme.magentaNeon
                            : StackMoneyTheme.cyanNeon,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
