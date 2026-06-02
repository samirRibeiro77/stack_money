import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';

class TelemetryFilterChip extends StatelessWidget {
  const TelemetryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    this.onTap,
  });

  final String label;
  final bool isSelected;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSizes.x2),
        child: GestureDetector(
          onTap: onTap,
          child: GlassmorphismEffect(
            backgroundColor: StackMoneyTheme.background,
            containerHeight: AppSizes.x20,
            borderColor: isSelected ? StackMoneyTheme.magentaNeon : null,
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: isSelected
                      ? StackMoneyTheme.cyanNeon
                      : StackMoneyTheme.mutedGrey,
                  fontWeight: isSelected
                      ? AppTypography.weightBold
                      : AppTypography.weightNormal,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
