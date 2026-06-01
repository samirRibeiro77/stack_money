import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/matrix_nav_tabs.dart';

class MatrixCapsuleItem extends StatelessWidget {
  const MatrixCapsuleItem({
    super.key,
    required this.tab,
    required this.currentTabIndex,
  });

  final MatrixNavTabs tab;
  final ValueNotifier<MatrixNavTabs> currentTabIndex;

  @override
  Widget build(BuildContext context) {
    final bool isActive = currentTabIndex.value == tab;
    final Color itemColor = isActive
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.mutedGrey;
    final double increaseSize = isActive ? 2 : 0;

    return GestureDetector(
      onTap: () => currentTabIndex.value = tab,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.x4,
          vertical: AppSizes.x2,
        ),
        transform: Matrix4.identity()..scale(isActive ? 1.12 : 1.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              tab.icon,
              color: itemColor,
              size: AppSizes.navBarIconSize + increaseSize,
              shadows: isActive
                  ? [
                      Shadow(
                        color: StackMoneyTheme.cyanNeon.withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: (9 + increaseSize),
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: itemColor,
                letterSpacing: 0.5,
              ),
              child: Text(tab.name.toUpperCase()),
            ),
          ],
        ),
      ),
    );
  }
}
