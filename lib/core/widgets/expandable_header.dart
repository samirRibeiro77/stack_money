import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/title_text.dart';

class ExpandableHeader extends StatelessWidget {
  const ExpandableHeader({
    required this.title,
    required this.toggleExpand,
    required this.expandState,
    super.key,
  });

  final String title;
  final VoidCallback toggleExpand;
  final ValueListenable<bool> expandState;

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
              onPressed: toggleExpand,
              icon: ValueListenableBuilder<bool>(
                valueListenable: expandState,
                builder: (_, isExpanded, _) {
                  return Icon(
                    isExpanded ? Icons.unfold_more : Icons.unfold_less,
                    color: isExpanded
                        ? StackMoneyTheme.cyanNeon
                        : StackMoneyTheme.magentaNeon,
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
