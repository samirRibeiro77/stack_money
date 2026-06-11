import 'package:flutter/material.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';

class TitleText extends StatelessWidget {
  const TitleText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Text(
      StackMoneyString.formatTitle(text),
      style: textTheme.titleSmall?.copyWith(
        color: StackMoneyTheme.mutedGrey,
        letterSpacing: 1.5,
      ),
    );
  }
}
