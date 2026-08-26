import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class LoadingLinearProgressBar extends StatelessWidget {
  const LoadingLinearProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
      child: Container(
        height: AppSizes.x4,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: StackMoneyTheme.mutedGrey),
          borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [StackMoneyTheme.magentaNeon, StackMoneyTheme.cyanNeon],
          ).createShader(bounds),
          child: const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            valueColor: AlwaysStoppedAnimation<Color>(
              StackMoneyTheme.platinumSilver,
            ),
          ),
        ),
      ),
    );
  }
}
