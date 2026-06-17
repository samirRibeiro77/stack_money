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
    required this.activeIcon,
    required this.inactiveIcon,
    this.activeColor = StackMoneyTheme.cyanNeon,
    this.inactiveColor = StackMoneyTheme.magentaNeon,
    super.key,
  });

  final String title;
  final VoidCallback toggle;
  final ValueListenable<bool> validation;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final Color activeColor;
  final Color inactiveColor;

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return SizedBox(
      height: AppSizes.x10,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          TitleText(title),
          if (!isSecureActive)
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: toggle,
              icon: ValueListenableBuilder<bool>(
                valueListenable: validation,
                builder: (_, isExpanded, _) {
                  return Icon(
                    isExpanded ? activeIcon : inactiveIcon,
                    color: isExpanded
                        ? activeColor
                        : inactiveColor,
                    size: AppSizes.x10,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
