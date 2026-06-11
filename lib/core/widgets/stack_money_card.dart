import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/title_text.dart';

class StackMoneyCard extends StatelessWidget {
  final String? title;
  final Widget child;
  final Color shadowColor;
  final bool removePadding;

  const StackMoneyCard({
    this.title,
    required this.child,
    this.removePadding = false,
    this.shadowColor = StackMoneyTheme.cyanNeon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        vertical: removePadding ? 0 : AppSizes.x10,
        horizontal: removePadding ? 0 : AppSizes.x8,
      ),
      decoration: BoxDecoration(
        color: StackMoneyTheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        boxShadow: !isSecureActive
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
            TitleText(title!),
            const SizedBox(height: AppSizes.x8),
          ],

          // Card custom body
          child,
        ],
      ),
    );
  }
}
