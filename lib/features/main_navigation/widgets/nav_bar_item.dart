import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/nav_bar_tabs.dart';

class NavBarItem extends StatelessWidget {
  const NavBarItem({
    super.key,
    required this.tab,
    required this.changeTab,
    required this.isActive,
  });

  final NavBarTabs tab;
  final bool isActive;
  final ValueChanged<NavBarTabs> changeTab;

  @override
  Widget build(BuildContext context) {
    final Color itemColor = isActive
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.mutedGrey;
    final double increaseSize = isActive ? 2 : 0;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => changeTab(tab),
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
                        color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.5),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            const SizedBox(height: AppSizes.min),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: textTheme.titleSmall!.copyWith(
                fontSize: (AppTypography.navBar + increaseSize),
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
