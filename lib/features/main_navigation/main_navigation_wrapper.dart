import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/widgets/user_header.dart';
import 'package:stack_money/data/enum/nav_bar_tabs.dart';
import 'package:stack_money/features/main_navigation/manager/main_navigation_manager.dart';
import 'package:stack_money/features/main_navigation/widgets/floating_nav_bar.dart';

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
    final bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _manager.scrollController,
            slivers: [
              /// User header info and options
              UserHeader(
                isSecurity: _manager.securityMode,
                switchSecurity: _manager.switchSecurityMode,
              ),

              /// Body
              SliverFillRemaining(
                hasScrollBody: false,
                child: ValueListenableBuilder<NavBarTabs>(
                  valueListenable: _manager.currentTab,
                  builder: (_, activeIndex, _) {
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInCubic,
                      switchOutCurve: Curves.easeOutCubic,
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                      child: _manager.activeSliverFragment(activeIndex),
                    );
                  },
                ),
              ),
            ],
          ),

          /// Bottom nav bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.fastOutSlowIn,
            left: AppSizes.x12,
            right: AppSizes.x12,
            bottom: isKeyboardActive
                ? -AppSizes.navBarContentPadding
                : AppSizes.navBarPaddingBottom,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isKeyboardActive ? 0.0 : 1.0,
              child: FloatingNavBar(
                changeTab: (t) => _manager.changeTab(t),
                currentTab: _manager.currentTab,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
