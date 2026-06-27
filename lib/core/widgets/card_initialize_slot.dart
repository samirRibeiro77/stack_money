import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';

class CardInitializeSlot extends StatelessWidget {
  const CardInitializeSlot(this.text, {required this.onTap, super.key});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return GestureDetector(
      onTap: !isSecureActive ? onTap : null,
      child: Container(
        height: AppSizes.x26,
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x4),
        child: CustomPaint(
          painter: _MatrixDashedPainter(
            color: StackMoneyTheme.mutedGrey.withValues(alpha: 0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: StackMoneyTheme.mutedGrey.withValues(alpha: 0.4),
              ),
              const SizedBox(width: AppSizes.sizedBoxSmall),
              Text(
                StackMoneyString.formatTitle(text),
                style: textTheme.titleSmall?.copyWith(
                  color: StackMoneyTheme.mutedGrey.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 🎨 ENGINE DE PINTURA TRACEJADA CYBERPUNK NATIVA
class _MatrixDashedPainter extends CustomPainter {
  _MatrixDashedPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(AppSizes.x6),
    );

    final Path path = Path()..addRRect(rrect);
    const double dashWidth = AppSizes.x3;
    const double dashSpace = AppSizes.x2;

    final Path metricsPath = Path();
    for (final PathMetric metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double length = (distance + dashWidth < metric.length)
            ? dashWidth
            : metric.length - distance;
        metricsPath.addPath(
          metric.extractPath(distance, distance + length),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(metricsPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
