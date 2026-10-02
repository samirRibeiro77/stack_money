import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/title_text.dart';

class ExpandableHeader extends StatelessWidget {
  const ExpandableHeader({
    required this.title,
    required this.toggle,
    required this.validation,
    this.activeIcon = Icons.unfold_more,
    this.inactiveIcon = Icons.unfold_less,
    this.activeColor = StackMoneyTheme.cyanNeon,
    this.inactiveColor = StackMoneyTheme.magentaNeon,
    this.showIcon = true,
    super.key,
  });

  final String title;
  final VoidCallback toggle;
  final ValueListenable<bool> validation;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final Color inactiveColor;
  final bool showIcon;

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: toggle,
      child: SizedBox(
        height: AppSizes.x10,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TitleText(title),
            if (!isSecureActive && showIcon)
              ValueListenableBuilder<bool>(
                valueListenable: validation,
                builder: (_, isExpanded, _) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          return ScaleTransition(
                            scale: animation,
                            child: RotationTransition(
                              turns: animation,
                              child: child,
                            ),
                          );
                        },
                    child: Icon(
                      isExpanded ? activeIcon : inactiveIcon,
                      key: ValueKey('${title}_${validation.value}'),
                      color: isExpanded ? activeColor : inactiveColor,
                      size: AppSizes.x10,
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
