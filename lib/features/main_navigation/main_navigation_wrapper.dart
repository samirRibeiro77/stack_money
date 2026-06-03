import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/widgets/user_header.dart';
import 'package:stack_money/data/enum/matrix_nav_tabs.dart';
import 'package:stack_money/features/main_navigation/manager/main_navigation_manager.dart';
import 'package:stack_money/features/main_navigation/widgets/floating_matrix_capsule.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  static const route = '/main_control';

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final _manager = MainNavigationManager();

  @override
  void initState() {
    super.initState();
    _manager.addTabListener(() {
      if (_manager.scrollController.hasClients) {
        _manager.scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 📺 CAMADA 0: O Scroll Mestre Unificado do App (Sliver Viewport Matrix)
          CustomScrollView(
            controller: _manager.scrollController,
            slivers: [
              // 🛰️ HEADER GLOBAL: Fixo no topo
              UserHeader(isSecurity: _manager.securityMode, switchSecurity: _manager.switchSecurityMode,),

              // 🧪 ADAPTADOR ANIMADO: Gerencia o Cross-Fade entre os Boxes das abas
              SliverFillRemaining(
                hasScrollBody: false, // 💥 ESSENCIAL: Permite que a Column interna mande no scroll
                child: ValueListenableBuilder<MatrixNavTabs>(
                  valueListenable: _manager.currentTab,
                  builder: (context, activeIndex, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInCubic,
                      switchOutCurve: Curves.easeOutCubic, // Sua curva de preferência
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _manager.activeSliverFragment(activeIndex),
                    );
                  },
                ),
              ),
            ],
          ),

          // 🛸 CAMADA 1: A Floating Matrix Capsule Orbital (70% compacta e transparente)
          Positioned(
            left: AppSizes.x12,
            right: AppSizes.x12,
            bottom: AppSizes.navBarPaddingBottom,
            child: FloatingMatrixCapsule(changeTab: (t) => _manager.changeTab(t), currentTab: _manager.currentTab,),
          ),
        ],
      ),
    );
  }
}
