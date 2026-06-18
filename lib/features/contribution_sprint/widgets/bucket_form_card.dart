import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketFormCard extends StatelessWidget {
  final Bucket bucket;
  final TextEditingController nameController;
  final TextEditingController whereController;
  final TextEditingController minValueController;
  final TextEditingController actualValueController;

  // Rótulos puros e limpos repassados pela camada de View principal
  final String labelLastValueKnown;
  final String labelActualValue;
  final String labelCategory;
  final String labelWhere;
  final String labelMinValue;
  final String statusLiquid;
  final String statusLocked;

  const BucketFormCard({
    required this.bucket,
    required this.nameController,
    required this.whereController,
    required this.minValueController,
    required this.actualValueController,
    required this.labelLastValueKnown,
    required this.labelActualValue,
    required this.labelCategory,
    required this.labelWhere,
    required this.labelMinValue,
    required this.statusLiquid,
    required this.statusLocked,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return StackMoneyCard(
      shadowColor: bucket.isImmediateLiquidity ? StackMoneyTheme.cyanNeon : StackMoneyTheme.magentaNeon,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bucket.name.toUpperCase(),
            style: textTheme.titleMedium?.copyWith(fontWeight: AppTypography.weightBold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                  labelLastValueKnown,
                  style: textTheme.labelSmall?.copyWith(color: StackMoneyTheme.mutedGrey)
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSizes.x2, vertical: AppSizes.min),
                decoration: BoxDecoration(
                    color: (bucket.isImmediateLiquidity ? StackMoneyTheme.cyanNeon : StackMoneyTheme.magentaNeon).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSizes.min),
                    border: Border.all(
                      color: (bucket.isImmediateLiquidity ? StackMoneyTheme.cyanNeon : StackMoneyTheme.magentaNeon).withValues(alpha: 0.3),
                      width: 0.5,
                    )
                ),
                child: Text(
                  bucket.isImmediateLiquidity ? statusLiquid : statusLocked,
                  style: textTheme.labelSmall?.copyWith(
                    color: bucket.isImmediateLiquidity ? StackMoneyTheme.cyanNeon : StackMoneyTheme.magentaNeon,
                    fontWeight: AppTypography.weightBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSizes.x6),
          const Divider(),
          const SizedBox(height: AppSizes.x6),

          TextFormField(
            controller: nameController,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(labelCategory),
          ),
          const SizedBox(height: AppSizes.x5),

          TextFormField(
            controller: whereController,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(labelWhere),
          ),
          const SizedBox(height: AppSizes.x5),

          TextFormField(
            controller: minValueController,
            keyboardType: TextInputType.number,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(labelMinValue),
            inputFormatters: [MoneyInputFormatter()],
          ),
          const SizedBox(height: AppSizes.x8),

          TextFormField(
            controller: actualValueController,
            keyboardType: TextInputType.number,
            autofocus: true,
            style: textTheme.bodyMedium?.copyWith(fontWeight: AppTypography.weightBold, color: StackMoneyTheme.cyanNeon),
            decoration: StackMoneyTheme.inputDecoration(labelActualValue).copyWith(
                focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: StackMoneyTheme.cyanNeon, width: 1.5)
                )
            ),
            inputFormatters: [MoneyInputFormatter()],
          ),
        ],
      ),
    );
  }
}