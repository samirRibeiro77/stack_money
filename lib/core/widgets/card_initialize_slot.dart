import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';

class CardInitializeSlot extends StatelessWidget {
  const CardInitializeSlot(this.text, {required this.onTap, super.key});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppSizes.x26,
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x4),
        child: CustomPaint(
          painter: _MatrixDashedPainter(
            color: StackMoneyTheme.mutedGrey.withOpacity(0.35),
          ),
          child: Center(
            child: Text(
              '+ ${StackMoneyString.formatTitle(text)}',
              style: textTheme.labelSmall,
            ),
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
