import 'package:flutter/material.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/enum/matrix_nav_tabs.dart';
import 'package:stack_money/features/main_navigation/widgets/matrix_capsule_item.dart';

class FloatingMatrixCapsule extends StatelessWidget {
  const FloatingMatrixCapsule({super.key, required this.currentTabIndex});

  final ValueNotifier<MatrixNavTabs> currentTabIndex;

  @override
  Widget build(BuildContext context) {
    final double customWidth = MediaQuery.of(context).size.width * 0.70;

    return Center(
      child: SizedBox(
        width: customWidth,
        child: GlassmorphismEffect(
          child: ValueListenableBuilder(valueListenable: currentTabIndex, builder: (_, currentIndex, _) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: MatrixNavTabs.values
                  .map(
                    (t) => MatrixCapsuleItem(
                  tab: t,
                  currentTabIndex: currentTabIndex,
                ),
              )
                  .toList(),
            );
          }),
        ),
      ),
    );
  }
}
