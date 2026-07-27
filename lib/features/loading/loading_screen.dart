import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/features/main_navigation/main_navigation_wrapper.dart';

class LoadingScreen extends StatelessWidget {
  static final route = '/loading';

  const LoadingScreen({super.key});

  void navigateHome(BuildContext context) {
    final isLoading = AppCoordinator.instance.isLoading.value;
    if (!isLoading) {
      context.go(MainNavigationWrapper.route);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppCoordinator.instance.initApp();

    AppCoordinator.instance.isLoading.addListener(() => navigateHome(context));

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Text('Loading data'),
            CircularProgressIndicator.adaptive(),
          ],
        ),
      ),
    );
  }
}
