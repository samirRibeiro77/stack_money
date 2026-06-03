import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/data/enum/matrix_nav_tabs.dart';
import 'package:stack_money/features/dashboard/dashboard_screen.dart';
import 'package:stack_money/features/history/history_screen.dart';

class MainNavigationManager {
  final _tabIndex = ValueNotifier<MatrixNavTabs>(MatrixNavTabs.hud);
  final _securityMode = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();

  ValueListenable<MatrixNavTabs> get currentTab => _tabIndex;

  ValueListenable<bool> get securityMode => _securityMode;

  ScrollController get scrollController => _scrollController;

  void dispose() {
    _tabIndex.dispose();
    _securityMode.dispose();
    _scrollController.dispose();
  }

  void addTabListener(VoidCallback f) => _tabIndex.addListener(f);

  void switchSecurityMode() => _securityMode.value = !_securityMode.value;

  void changeTab(MatrixNavTabs tab) => _tabIndex.value = tab;

  Widget activeSliverFragment(MatrixNavTabs index) {
    switch (index) {
      case MatrixNavTabs.hud:
        return DashboardScreen(
          key: const ValueKey('dashboard_fragment'),
          securityMode: securityMode,
        );
      case MatrixNavTabs.plans:
        return Container(
          key: const ValueKey('plans_fragment'),
          child: Center(child: Text('Plans Tab')),
        );
      case MatrixNavTabs.log:
        return HistoryScreen(
          key: const ValueKey('history_fragment'),
          securityMode: securityMode,
        );
    }
  }
}
