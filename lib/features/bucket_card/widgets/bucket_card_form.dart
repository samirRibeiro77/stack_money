import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/money_input_formatter.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/bucket_card_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sign_toggle_button.dart';
import 'package:stack_money/data/enum/value_sign.dart';

class BucketCardForm extends StatelessWidget {
  const BucketCardForm({super.key});

  @override
  Widget build(BuildContext context) {
    final manager = BucketCardScope.of(context);
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<Color>(
      valueListenable: manager.techColor,
      builder: (context, techColor, _) {
        return Padding(
          padding: const EdgeInsets.all(AppSizes.x8),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: manager.whereController,
                      focusNode: manager.whereFocus,
                      style: textTheme.bodySmall,
                      decoration: StackMoneyTheme.inputDecoration(
                        l10n.where,
                        color: techColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSizes.sizedBoxMedium),
                  Expanded(
                    child: TextFormField(
                      controller: manager.categoryController,
                      focusNode: manager.categoryFocus,
                      style: textTheme.bodySmall,
                      decoration: StackMoneyTheme.inputDecoration(
                        l10n.category,
                        color: techColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSizes.sizedBoxMedium),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ValueListenableBuilder<ValueSign>(
                    valueListenable: manager.minValueSign,
                    builder: (_, sign, _) {
                      return SignToggleButton(
                        manager.toggleValueSign,
                        initialValue: sign,
                      );
                    },
                  ),
                  const SizedBox(width: AppSizes.sizedBoxMedium),
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: manager.minValueController,
                      keyboardType: TextInputType.number,
                      focusNode: manager.minValueFocus,
                      style: textTheme.bodySmall,
                      decoration: StackMoneyTheme.inputDecoration(
                        l10n.minValue,
                        color: techColor,
                      ),
                      inputFormatters: [MoneyInputFormatter()],
                    ),
                  ),
                  const SizedBox(width: AppSizes.sizedBoxMedium),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          StackMoneyString.formatTitle(l10n.liquidity),
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: AppTypography.fontSmallest,
                            color: StackMoneyTheme.mutedGrey,
                          ),
                        ),
                        SizedBox(
                          height: AppSizes.x16,
                          child: Center(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: ValueListenableBuilder<bool>(
                                valueListenable: manager.isImmediateLiquidity,
                                builder: (_, liquidity, _) {
                                  return Switch(
                                    value: liquidity,
                                    activeThumbColor: techColor,
                                    activeTrackColor: techColor.withValues(
                                      alpha: 0.15,
                                    ),
                                    inactiveThumbColor:
                                        StackMoneyTheme.mutedGrey,
                                    inactiveTrackColor: StackMoneyTheme.surface,
                                    onChanged: manager.updateLiquidity,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
