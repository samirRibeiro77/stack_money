import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/value_sign.dart';

class ValueSignButton extends StatelessWidget {
  ValueSignButton(
    this.toggleSign, {
    ValueSign initialValue = ValueSign.positive,
    super.key,
  }) : _valueSign = ValueNotifier(initialValue);

  final VoidCallback toggleSign;
  final ValueNotifier<ValueSign> _valueSign;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: toggleSign,
      child: ValueListenableBuilder(
        valueListenable: _valueSign,
        builder: (_, valueSign, _) {
          final techColor = valueSign == ValueSign.positive
              ? StackMoneyTheme.cyanNeon
              : StackMoneyTheme.magentaNeon;

          return Container(
            height: AppSizes.x17,
            width: AppSizes.x17,
            decoration: BoxDecoration(
              color: StackMoneyTheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.x4),
              border: Border.all(
                color: techColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                ' ${valueSign.sign} ',
                style: textTheme.bodyLarge?.copyWith(color: techColor),
              ),
            ),
          );
        },
      ),
    );
  }
}
