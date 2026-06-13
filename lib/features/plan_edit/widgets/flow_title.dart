import 'package:flutter/material.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/title_text.dart';

class FlowTitle extends StatelessWidget {
  const FlowTitle({
    required this.title,
    required this.balance,
    required this.toggleExpand,
    super.key,
  });

  final String title;
  final double balance;
  final VoidCallback toggleExpand;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: toggleExpand,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TitleText(StackMoneyString.formatTitle(title)),
          Text(
            StackMoneyString.formatMoney(doubleValue: balance),
            style: textTheme.titleMedium?.copyWith(
              color: StackMoneyTheme.cyanNeon,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
