import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class ErrorHeader extends StatelessWidget {
  final IconData icon;
  final String message;

  const ErrorHeader({required this.icon, required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: StackMoneyTheme.magentaNeon.withAlpha(100),
                blurRadius: 30,
                spreadRadius: 30,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: AppSizes.errorIcon,
            color: StackMoneyTheme.surface,
          ),
        ),
        SizedBox(height: AppSizes.errorPadding),
        Text(
          message,
          style: textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
