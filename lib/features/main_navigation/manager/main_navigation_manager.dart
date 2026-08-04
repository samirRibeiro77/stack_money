import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/data/enum/nav_bar_tabs.dart';

class MainNavigationManager {
  final _tabIndex = ValueNotifier<NavBarTabs>(NavBarTabs.hud);
  final _scrollController = ScrollController();

  ValueListenable<NavBarTabs> get currentTab => _tabIndex;

  ScrollController get scrollController => _scrollController;

  void dispose() {
    _tabIndex.dispose();
    _scrollController.dispose();
  }

  void addTabListener(VoidCallback f) => _tabIndex.addListener(f);

  void changeTab(NavBarTabs tab) => _tabIndex.value = tab;
}
