import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class GlassmorphismEffect extends StatelessWidget {
  const GlassmorphismEffect({
    super.key,
    this.containerHeight = AppSizes.x30,
    required this.child,
    this.borderColor = StackMoneyTheme.mutedGrey,
    this.backgroundColor = StackMoneyTheme.carbonGrey,
    this.borderWidth = 0.6,
  });

  final double? containerHeight;
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final borderColorFixed = borderColor ?? StackMoneyTheme.mutedGrey;
    final backgroundColorFixed = backgroundColor ?? StackMoneyTheme.carbonGrey;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: containerHeight,
          decoration: BoxDecoration(
            color: backgroundColorFixed.withOpacity(0.25),
            borderRadius: BorderRadius.circular(AppSizes.navBarRadius),
            border: Border.all(
              color: borderColorFixed.withOpacity(0.30),
              width: borderWidth,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppSizes.x4),
          child: child,
        ),
      ),
    );
  }
}
