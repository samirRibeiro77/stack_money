import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/plan_status.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketFormCard extends StatelessWidget {
  final Bucket bucket;
  final double lastKnowValue;
  final TextEditingController nameController;
  final TextEditingController whereController;
  final TextEditingController minValueController;
  final TextEditingController actualValueController;
  final VoidCallback changeLiquidity;

  const BucketFormCard({
    required this.bucket,
    required this.lastKnowValue,
    required this.nameController,
    required this.whereController,
    required this.minValueController,
    required this.actualValueController,
    required this.changeLiquidity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return StackMoneyCard(
      shadowColor: bucket.isImmediateLiquidity
          ? StackMoneyTheme.cyanNeon
          : StackMoneyTheme.magentaNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            StackMoneyString.formatTitle(bucket.name),
            style: textTheme.titleMedium?.copyWith(
              fontWeight: AppTypography.weightBold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${StackMoneyString.formatTitle(l10n.lastKnownValue)} ${StackMoneyString.formatMoney(lastKnowValue, symbol: true)}',
                style: textTheme.labelSmall?.copyWith(
                  color: StackMoneyTheme.mutedGrey,
                ),
              ),
              PlanStatus(
                bucket.isImmediateLiquidity ? l10n.liquid : l10n.invest,
                color: bucket.isImmediateLiquidity
                    ? StackMoneyTheme.cyanNeon
                    : StackMoneyTheme.magentaNeon,
                onTap: changeLiquidity,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.x6),
          const Divider(),
          const SizedBox(height: AppSizes.x6),

          TextFormField(
            controller: nameController,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(l10n.category),
          ),
          const SizedBox(height: AppSizes.x5),

          TextFormField(
            controller: whereController,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(l10n.where),
          ),
          const SizedBox(height: AppSizes.x5),

          TextFormField(
            controller: minValueController,
            keyboardType: TextInputType.number,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(l10n.minValue),
            inputFormatters: [MoneyInputFormatter()],
          ),
          const SizedBox(height: AppSizes.x8),

          TextFormField(
            controller: actualValueController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: textTheme.bodySmall?.copyWith(
              fontWeight: AppTypography.weightBold,
              color: StackMoneyTheme.cyanNeon,
            ),
            decoration: StackMoneyTheme.inputDecoration(l10n.actualValue)
                .copyWith(
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: StackMoneyTheme.cyanNeon,
                      width: 1.5,
                    ),
                  ),
                ),
            inputFormatters: [MoneyInputFormatter()],
          ),
        ],
      ),
    );
  }
}
