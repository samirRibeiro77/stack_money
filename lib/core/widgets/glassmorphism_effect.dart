import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class GlassmorphismEffect extends StatelessWidget {
  const GlassmorphismEffect({
    required this.child,
    this.containerHeight = AppSizes.x30,
    this.borderColor = StackMoneyTheme.mutedGrey,
    this.backgroundColor = StackMoneyTheme.carbonGrey,
    this.borderWidth = 0.6,
    this.borderRadius = AppSizes.navBarRadius,
    this.borderRadiusSpec,
    this.borderSpec,
    super.key,
  });

  final double? containerHeight;
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final double borderWidth;
  final double borderRadius;
  final BorderRadiusGeometry? borderRadiusSpec;
  final BoxBorder? borderSpec;

  @override
  Widget build(BuildContext context) {
    final borderColorFixed = borderColor ?? StackMoneyTheme.mutedGrey;
    final backgroundColorFixed = backgroundColor ?? StackMoneyTheme.carbonGrey;

    return ClipRRect(
      borderRadius: borderRadiusSpec ?? BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: containerHeight,
          decoration: BoxDecoration(
            color: backgroundColorFixed.withValues(alpha: 0.25),
            borderRadius:
                borderRadiusSpec ?? BorderRadius.circular(borderRadius),
            border:
                borderSpec ??
                Border.all(
                  color: borderColorFixed.withValues(alpha: 0.30),
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
