import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/value_sign.dart';

class SignToggleButton extends StatelessWidget {
  const SignToggleButton(
    this.toggleSign, {
    ValueSign initialValue = ValueSign.positive,
    super.key,
  }) : _valueSign = initialValue;

  final VoidCallback toggleSign;
  final ValueSign _valueSign;

  @override
  Widget build(BuildContext context) {
    final techColor = _valueSign == ValueSign.positive
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.magentaNeon;

    return GestureDetector(
      onTap: toggleSign,
      child: Container(
        height: AppSizes.x17,
        width: AppSizes.x17,
        decoration: BoxDecoration(
          color: StackMoneyTheme.surface,
          borderRadius: BorderRadius.circular(AppSizes.x4),
          border: Border.all(
            color: techColor.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(_valueSign.sign, color: techColor, size: AppSizes.x7),
        ),
      ),
    );
  }
}
