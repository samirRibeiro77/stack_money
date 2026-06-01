import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/matrix_nav_tabs.dart';
import 'package:stack_money/features/main_navigation/widgets/floating_matrix_capsule.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  static const route = '/main_control';

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final _currentTabIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      body: ValueListenableBuilder(
        valueListenable: _currentTabIndex,
        builder: (_, value, _) {
          return Stack(
            children: [
              // 📺 Camada 0: O Conteúdo do App ocupa a tela inteira
              IndexedStack(
                index: value,
                children: MatrixNavTabs.values.map((m) => m.page).toList(),
              ),

              // 🛸 Camada 1: A Floating Matrix Capsule Flutuando por Cima
              Positioned(
                left: AppSizes.x12,
                right: AppSizes.x12,
                bottom: AppSizes.navBarPaddingBottom,
                child: FloatingMatrixCapsule(currentTabIndex: _currentTabIndex),
              ),
            ],
          );
        },
      ),
    );
  }
}
