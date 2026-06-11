import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/data/enum/nav_bar_tabs.dart';
import 'package:stack_money/features/buckets/buckets_screen.dart';
import 'package:stack_money/features/dashboard/dashboard_screen.dart';
import 'package:stack_money/features/history/history_screen.dart';

class MainNavigationManager {
  final _tabIndex = ValueNotifier<NavBarTabs>(NavBarTabs.hud);
  final _securityMode = ValueNotifier<bool>(false);
  final _scrollController = ScrollController();

  ValueListenable<NavBarTabs> get currentTab => _tabIndex;

  ValueListenable<bool> get securityMode => _securityMode;

  ScrollController get scrollController => _scrollController;

  void dispose() {
    _tabIndex.dispose();
    _securityMode.dispose();
    _scrollController.dispose();
  }

  void addTabListener(VoidCallback f) => _tabIndex.addListener(f);

  void switchSecurityMode() => _securityMode.value = !_securityMode.value;

  void changeTab(NavBarTabs tab) => _tabIndex.value = tab;

  Widget activeSliverFragment(NavBarTabs index) {
    switch (index) {
      case NavBarTabs.hud:
        return DashboardScreen();
      case NavBarTabs.plans:
        return Container(
          key: const ValueKey('plans_fragment'),
          child: Center(child: Text('Plans Tab')),
        );
      case NavBarTabs.buckets:
        return BucketControlScreen();
      case NavBarTabs.log:
        return HistoryScreen(securityMode: securityMode);
    }
  }
}
