import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/bucket_card_scope.dart';
import 'package:stack_money/core/theme/theme.dart';

class BucketCardSavingAnimation extends StatelessWidget {
  final Widget child;

  const BucketCardSavingAnimation({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final manager = BucketCardScope.of(context);

    return ValueListenableBuilder<Color>(
      valueListenable: manager.techColor,
      builder: (_, techColor, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: manager.isSaving,
          builder: (_, saving, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
              decoration: BoxDecoration(
                color: StackMoneyTheme.surface,
                borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
                border: Border.all(
                  color: saving
                      ? techColor
                      : Colors.white.withValues(alpha: 0.04),
                  width: saving ? 1.0 : 0.5,
                ),
                boxShadow: saving
                    ? [
                        BoxShadow(
                          color: techColor.withValues(alpha: 0.3),
                          blurRadius: AppSizes.radiusSmall,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
        );
      },
    );
  }
}
