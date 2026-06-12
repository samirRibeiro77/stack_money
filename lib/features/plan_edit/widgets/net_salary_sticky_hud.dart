import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/salary_plan.dart';

class NetSalaryStickyHud extends SliverPersistentHeaderDelegate {
  final SalaryPlan plan;

  NetSalaryStickyHud({required this.plan});

  @override
  double get minExtent => 50.0; // Altura colapsada tática colada na appBar

  @override
  double get maxExtent => 85.0; // Altura expandida HUD original

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final double percent = (shrinkOffset / maxExtent).clamp(0.0, 1.0);
    final Color techColor = plan.isOverflowed ? StackMoneyTheme.magentaNeon : StackMoneyTheme.cyanNeon;

    // Calcula a porcentagem do salário líquido que já foi consumida
    double allocatedPercentage = plan.netSalary > 0 ? (plan.totalAllocated / plan.netSalary) : 0.0;
    if (allocatedPercentage > 1.0) allocatedPercentage = 1.0;

    return Container(
      color: StackMoneyTheme.background,
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: StackMoneyTheme.surface,
          borderRadius: BorderRadius.circular(percent > 0.8 ? 8 : 12),
          border: Border.all(color: techColor.withOpacity(0.15), width: 0.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      percent > 0.6 ? 'NET_BUFFER: ' : 'NET_SALARY_BUFFER: ',
                      style: TextStyle(
                          fontFamily: 'Orbitron',
                          fontSize: percent > 0.6 ? 11 : 12,
                          fontWeight: FontWeight.bold,
                          color: StackMoneyTheme.platinumSilver
                      ),
                    ),
                    Text(
                      StackMoneyString.formatMoney(doubleValue: plan.netSalary),
                      style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: percent > 0.6 ? 11 : 13, color: StackMoneyTheme.platinumSilver),
                    ),
                  ],
                ),
                Text(
                  plan.isOverflowed
                      ? '[ OVERFLOW_DEGRADED ]'
                      : 'REST: ${StackMoneyString.formatMoney(doubleValue: plan.remainingRest)}',
                  style: TextStyle(
                      fontFamily: 'JetBrainsMono',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: techColor
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.x2),

            // 📊 BARRA DE PROGRESSO INTELIGENTE CYBERPUNK
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: allocatedPercentage,
                minHeight: 4,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: techColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant NetSalaryStickyHud oldDelegate) {
    return oldDelegate.plan != plan;
  }
}