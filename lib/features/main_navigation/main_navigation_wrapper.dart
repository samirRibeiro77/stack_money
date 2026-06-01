import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/user_header.dart';
import 'package:stack_money/data/enum/matrix_nav_tabs.dart';
import 'package:stack_money/features/dashboard/dashboard_screen.dart';
import 'package:stack_money/features/main_navigation/widgets/floating_matrix_capsule.dart';

class MainNavigationWrapper extends StatefulWidget {
  const MainNavigationWrapper({super.key});

  static const route = '/main_control';

  @override
  State<MainNavigationWrapper> createState() => _MainNavigationWrapperState();
}

class _MainNavigationWrapperState extends State<MainNavigationWrapper> {
  final _currentTabIndex = ValueNotifier<MatrixNavTabs>(MatrixNavTabs.hud);
  final _globalVisibilityNotifier = ValueNotifier<bool>(false);
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Reseta o scroll automaticamente para o topo sempre que o usuário mudar de aba
    _currentTabIndex.addListener(() {
      if (_mainScrollController.hasClients) {
        _mainScrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _currentTabIndex.dispose();
    _globalVisibilityNotifier.dispose();
    _mainScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      body: Stack(
        children: [
          // 📺 CAMADA 0: O Scroll Mestre Unificado do App (Sliver Viewport Matrix)
          CustomScrollView(
            controller: _mainScrollController,
            slivers: [
              // 🛰️ HEADER GLOBAL: Fixo no topo
              UserHeader(visibilityNotifier: _globalVisibilityNotifier),

              // 🧪 ADAPTADOR ANIMADO: Gerencia o Cross-Fade entre os Boxes das abas
              SliverFillRemaining(
                hasScrollBody: false, // 💥 ESSENCIAL: Permite que a Column interna mande no scroll
                child: ValueListenableBuilder<MatrixNavTabs>(
                  valueListenable: _currentTabIndex,
                  builder: (context, activeIndex, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInCubic,
                      switchOutCurve: Curves.easeOutCubic, // Sua curva de preferência
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _buildActiveSliverFragment(activeIndex),
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
            child: FloatingMatrixCapsule(currentTabIndex: _currentTabIndex),
          ),
        ],
      ),
    );
  }

  /// 🛠️ Fábrica de Fragmentos: Injeta o estado global de privacidade em cada tela filha
  Widget _buildActiveSliverFragment(MatrixNavTabs index) {
    // Usamos chaves únicas para forçar o AnimatedSwitcher a disparar o Cross-Fade
    switch (index) {
      case MatrixNavTabs.hud:
        return DashboardScreen(
          key: const ValueKey('dashboard_fragment'),
          globalVisibility: _globalVisibilityNotifier,
        );
      case MatrixNavTabs.history:
        return HistoryScreenPlaceholder(
          key: const ValueKey('history_fragment'),
          globalVisibility: _globalVisibilityNotifier,
        );
      case MatrixNavTabs.plans:
        return PlansScreenPlaceholder(
          key: const ValueKey('plans_fragment'),
          globalVisibility: _globalVisibilityNotifier,
        );
    }
  }
}

// 📌 Placeholders temporários preparados para receber o protocolo de segurança
class HistoryScreenPlaceholder extends StatelessWidget {
  final ValueNotifier<bool> globalVisibility;
  const HistoryScreenPlaceholder({required this.globalVisibility, super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('HISTORY_LOG_STREAM', style: TextStyle(fontFamily: 'Orbitron', color: Colors.white)));
}

class PlansScreenPlaceholder extends StatelessWidget {
  final ValueNotifier<bool> globalVisibility;
  const PlansScreenPlaceholder({required this.globalVisibility, super.key});
  @override Widget build(BuildContext context) => const Center(child: Text('PLANS_CORE_GATEWAY', style: TextStyle(fontFamily: 'Orbitron', color: Colors.white)));
}