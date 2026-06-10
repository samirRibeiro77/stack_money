import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';

class TabContent extends StatelessWidget {
  const TabContent({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: AppSizes.x8,
        horizontal: AppSizes.x8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          child,
          const SizedBox(height: AppSizes.navBarContentPadding),
        ],
      ),
    );
  }
}
