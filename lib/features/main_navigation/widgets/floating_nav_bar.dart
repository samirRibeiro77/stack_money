import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/nav_bar_tabs.dart';
import 'package:stack_money/features/main_navigation/widgets/nav_bar_item.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.currentTab,
    required this.changeTab,
  });

  final ValueListenable<NavBarTabs> currentTab;
  final ValueChanged<NavBarTabs> changeTab;

  @override
  Widget build(BuildContext context) {
    final double customWidth = MediaQuery.of(context).size.width * 0.75;

    return Center(
      child: SizedBox(
        width: customWidth,
        height: AppSizes.navBarHeight,
        child: GlassmorphismEffect(
          child: ValueListenableBuilder(
            valueListenable: currentTab,
            builder: (_, currentIndex, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: NavBarTabs.values
                    .map(
                      (t) => NavBarItem(
                        tab: t,
                        changeTab: (t) => changeTab(t),
                        isActive: currentTab.value == t,
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
