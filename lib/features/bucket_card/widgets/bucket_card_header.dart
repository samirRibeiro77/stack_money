import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/providers/bucket_card_scope.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/enum/value_sign.dart';

class BucketCardHeader extends StatelessWidget {
  final bool isExpanded;
  final VoidCallback onHeaderTap;

  const BucketCardHeader({
    required this.isExpanded,
    required this.onHeaderTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final manager = BucketCardScope.of(context);
    final isSecureActive = SecurityProvider.isSecureOf(context);
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<Color>(
      valueListenable: manager.techColor,
      builder: (_, techColor, _) {
        return GestureDetector(
          onTap: () {
            if (isSecureActive) return;
            onHeaderTap();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.x8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<bool>(
                  valueListenable: manager.isImmediateLiquidity,
                  builder: (_, liquidity, _) {
                    return Container(
                      width: AppSizes.x2,
                      height: AppSizes.x12,
                      decoration: BoxDecoration(
                        color: liquidity
                            ? techColor
                            : StackMoneyTheme.mutedGrey.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusLarge,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: AppSizes.sizedBoxSmall),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: manager.categoryController,
                      builder: (_, value, _) {
                        return SecurityText(
                          StackMoneyString.formatTitle(value.text),
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                          type: SecurityType.systemLocked,
                        );
                      },
                    ),
                    ValueListenableBuilder<TextEditingValue>(
                      valueListenable: manager.whereController,
                      builder: (_, value, _) {
                        return SecurityText(
                          StackMoneyString.formatTitle(value.text),
                          style: textTheme.titleSmall?.copyWith(
                            fontSize: AppTypography.fontSmallest,
                          ),
                          activeColor: StackMoneyTheme.mutedGrey,
                        );
                      },
                    ),
                  ],
                ),
                const Expanded(child: SizedBox()),
                ValueListenableBuilder<ValueSign>(
                  valueListenable: manager.minValueSign,
                  builder: (_, sign, _) {
                    return ValueListenableBuilder<TextEditingValue>(
                      valueListenable: manager.minValueController,
                      builder: (_, value, _) {
                        var minValue =
                            StackMoneyNumber.parseMoneyStringToDouble(
                              value.text,
                            );
                        if (sign.isNegative) minValue = -minValue;

                        return SecurityText(
                          StackMoneyString.formatMoney(minValue, symbol: true),
                          type: SecurityType.mask,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: AppTypography.weightBold,
                          ),
                          activeColor: techColor,
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
