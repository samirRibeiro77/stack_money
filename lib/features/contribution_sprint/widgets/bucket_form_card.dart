import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/plan_status.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/core/widgets/value_sign_button.dart';
import 'package:stack_money/data/enum/value_sign.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketFormCard extends StatelessWidget {
  final Bucket bucket;
  final double lastKnowValue;
  final TextEditingController categoryController;
  final TextEditingController whereController;
  final TextEditingController minValueController;
  final TextEditingController actualValueController;
  final VoidCallback switchLiquidity;
  final Function(bool) setMinSign;
  final VoidCallback switchActualSign;

  BucketFormCard({
    required this.bucket,
    required this.lastKnowValue,
    required this.categoryController,
    required this.whereController,
    required this.minValueController,
    required this.actualValueController,
    required this.switchLiquidity,
    required this.setMinSign,
    required this.switchActualSign,
    super.key,
  }) : _isLiquidity = ValueNotifier(bucket.isImmediateLiquidity);

  final _minIsPositive = ValueNotifier(true);

  ValueListenable get _minListenable => _minIsPositive;

  final _actualIsPositive = ValueNotifier(true);

  ValueListenable get _actualListenable => _actualIsPositive;

  final ValueNotifier<bool> _isLiquidity;

  ValueListenable get _liquidityListenable => _isLiquidity;

  void changeMinSign(bool value) {
    _minIsPositive.value = value;
    setMinSign(value);
  }

  void changeActualSign() {
    _actualIsPositive.value = !_actualIsPositive.value;
    switchActualSign();
  }

  void changeLiquidity() {
    _isLiquidity.value = !_isLiquidity.value;
    switchLiquidity();
  }

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
          _buildTitle(textTheme),
          _buildHeader(l10n, textTheme),
          const SizedBox(height: AppSizes.x6),
          const Divider(),
          const SizedBox(height: AppSizes.x6),
          _buildName(l10n, textTheme),
          const SizedBox(height: AppSizes.x5),
          _buildMinValue(l10n, textTheme),
          const SizedBox(height: AppSizes.x8),
          _buildActualValue(l10n, textTheme),
        ],
      ),
    );
  }

  Widget _buildTitle(TextTheme textTheme) {
    return ValueListenableBuilder(
      valueListenable: categoryController,
      builder: (_, category, _) {
        return ValueListenableBuilder(
          valueListenable: whereController,
          builder: (_, where, _) {
            final name = '${where.text} ${category.text}';
            return Text(
              StackMoneyString.formatTitle(name),
              style: textTheme.titleSmall?.copyWith(
                fontWeight: AppTypography.weightBold,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(AppLocalizations l10n, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${StackMoneyString.formatTitle(l10n.lastKnownValue)} ${StackMoneyString.formatMoney(lastKnowValue, symbol: true)}',
          style: textTheme.labelSmall?.copyWith(
            color: StackMoneyTheme.mutedGrey,
          ),
        ),
        ValueListenableBuilder(
          valueListenable: _liquidityListenable,
          builder: (_, isLiquidity, _) {
            return PlanStatus(
              isLiquidity ? l10n.liquid : l10n.invest,
              color: isLiquidity
                  ? StackMoneyTheme.cyanNeon
                  : StackMoneyTheme.magentaNeon,
              onTap: changeLiquidity,
            );
          },
        ),
      ],
    );
  }

  Widget _buildName(AppLocalizations l10n, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: whereController,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(l10n.where),
          ),
        ),
        const SizedBox(width: AppSizes.x6),
        Expanded(
          child: TextFormField(
            controller: categoryController,
            style: textTheme.bodySmall,
            decoration: StackMoneyTheme.inputDecoration(l10n.category),
          ),
        ),
      ],
    );
  }

  Widget _buildMinValue(AppLocalizations l10n, TextTheme textTheme) {
    final minMoney = StackMoneyString.formatMoney(
      bucket.minValue,
      symbol: true,
    );

    return Row(
      children: [
        ValueSignButton(
          () => changeMinSign(false),
          initialValue: ValueSign.negative,
        ),
        const SizedBox(width: AppSizes.x6),
        ValueListenableBuilder(
          valueListenable: _minListenable,
          builder: (_, isPositive, _) {
            final techColor = isPositive
                ? StackMoneyTheme.cyanNeon
                : StackMoneyTheme.magentaNeon;

            final minInput =
                '${StackMoneyString.formatTitle(isPositive ? l10n.addToMin : l10n.subToMin)} $minMoney';

            return Expanded(
              child: TextFormField(
                controller: minValueController,
                keyboardType: TextInputType.number,
                style: textTheme.bodySmall,
                decoration: StackMoneyTheme.inputDecoration(
                  minInput,
                  useUnderline: false,
                  color: techColor,
                ),
                inputFormatters: [MoneyInputFormatter()],
              ),
            );
          },
        ),
        const SizedBox(width: AppSizes.x6),
        ValueSignButton(
          () => changeMinSign(true),
          initialValue: ValueSign.positive,
        ),
      ],
    );
  }

  Widget _buildActualValue(AppLocalizations l10n, TextTheme textTheme) {
    return ValueListenableBuilder(
      valueListenable: _actualListenable,
      builder: (_, isPositive, _) {
        final techColor = isPositive
            ? StackMoneyTheme.cyanNeon
            : StackMoneyTheme.magentaNeon;
        final initialValue = isPositive
            ? ValueSign.positive
            : ValueSign.negative;

        return Row(
          children: [
            ValueSignButton(changeActualSign, initialValue: initialValue),
            const SizedBox(width: AppSizes.x6),
            Expanded(
              child: TextFormField(
                controller: actualValueController,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: AppTypography.weightBold,
                  color: techColor,
                ),
                decoration:
                    StackMoneyTheme.inputDecoration(
                      isPositive
                          ? l10n.positiveActualValue
                          : l10n.negativeActualValue,
                      color: techColor,
                    ).copyWith(
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: techColor, width: 1.5),
                      ),
                    ),
                inputFormatters: [MoneyInputFormatter()],
              ),
            ),
          ],
        );
      },
    );
  }
}
