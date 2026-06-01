import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class GlassmorphismEffect extends StatelessWidget {
  const GlassmorphismEffect({
    super.key,
    this.containerHeight = 60.0,
    required this.child,
  });

  final double containerHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: Container(
          height: containerHeight,
          decoration: BoxDecoration(
            color: StackMoneyTheme.carbonGrey.withOpacity(0.25),
            borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
            border: Border.all(
              color: StackMoneyTheme.mutedGrey.withOpacity(0.30),
              width: 0.6,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.x4),
          child: child,
        ),
      ),
    );
  }
}
