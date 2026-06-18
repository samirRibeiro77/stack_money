import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';

class SprintProgressBar extends StatelessWidget {
  final int current;
  final int total;

  const SprintProgressBar({
    required this.current,
    required this.total,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final double factor = ((current + 1) / total).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      height: AppSizes.x2,
      color: Colors.white.withValues(alpha: 0.03),
      child: Align(
        alignment: Alignment.centerLeft,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: MediaQuery.of(context).size.width * factor,
          height: AppSizes.x2,
          decoration: const BoxDecoration(
            color: StackMoneyTheme.platinumSilver,
            boxShadow: [
              BoxShadow(
                color: StackMoneyTheme.platinumSilver,
                blurRadius: AppSizes.x2,
                spreadRadius: 0.5,
              )
            ],
          ),
        ),
      ),
    );
  }
}