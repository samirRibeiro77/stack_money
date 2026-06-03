import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';

class StackMoneyCard extends StatelessWidget {
  final String? title;
  final ValueListenable<bool> securityMode;
  final List<Widget> children;
  final Color shadowColor;

  const StackMoneyCard({
    super.key,
    this.title,
    required this.securityMode,
    required this.children,
    this.shadowColor = StackMoneyTheme.cyanNeon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<bool>(
      valueListenable: securityMode,
      builder: (context, isVisible, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.x10,
            horizontal: AppSizes.x8,
          ),
          decoration: BoxDecoration(
            color: StackMoneyTheme.surface,
            borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
            boxShadow: isVisible
                ? [
                    BoxShadow(
                      color: shadowColor.withValues(alpha: 0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null) ...[
                Text(
                  StackMoneyString.formatTitle(title!),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: AppTypography.weightBold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: AppSizes.x8),
              ],

              // Card custom body
              ...children,
            ],
          ),
        );
      },
    );
  }
}
