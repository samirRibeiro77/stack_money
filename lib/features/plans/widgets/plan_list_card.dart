import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';

class PlanListCard extends StatelessWidget {
  final SalaryPlan plan;
  final VoidCallback onTap;

  const PlanListCard(this.plan, {required this.onTap, super.key});

  Color get shadowColor {
    if (plan.isActive) return StackMoneyTheme.cyanNeon;
    if (plan.isArchived) return StackMoneyTheme.magentaNeon;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x3),
      child: GestureDetector(
        onTap: onTap,
        child: SmCard(
          shadowColor: shadowColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SecurityText(
                    StackMoneyString.formatTitle(plan.name),
                    style: textTheme.titleSmall,
                    type: SecurityType.systemLocked,
                  ),
                  if (plan.isActive)
                    SmChipButton(l10n.activePlan),
                ],
              ),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        StackMoneyString.formatTitle(l10n.grossRevenue),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.fontSmallest,
                          color: StackMoneyTheme.mutedGrey,
                        ),
                      ),
                      const SizedBox(height: AppSizes.min),
                      SecurityText(
                        StackMoneyString.formatMoney(plan.totalGrossSalary, symbol: true),
                        type: SecurityType.mask,
                        style: textTheme.bodyMedium,
                        activeColor: StackMoneyTheme.platinumSilver,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        StackMoneyString.formatTitle(l10n.remainingRest),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: AppTypography.fontSmallest,
                          color: StackMoneyTheme.mutedGrey,
                        ),
                      ),
                      const SizedBox(height: AppSizes.min),
                      SecurityText(
                        StackMoneyString.formatMoney(plan.remainingRest, symbol: true),
                        type: SecurityType.mask,
                        style: textTheme.bodyMedium?.copyWith(
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