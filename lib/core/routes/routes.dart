import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/models/salary_plan.dart';
import 'package:stack_money/domain/service/user_service.dart';
import 'package:stack_money/features/auth/login_screen.dart';
import 'package:stack_money/features/error/error_screen.dart';
import 'package:stack_money/features/loading/loading_screen.dart';
import 'package:stack_money/features/main_navigation/main_navigation_wrapper.dart';
import 'package:stack_money/features/personal_cfo/personal_cfo_screen.dart';
import 'package:stack_money/features/plan_edit/plan_edit_screen.dart';

final UserService _authService = UserService();

final GoRouter appRouter = GoRouter(
  initialLocation: LoginScreen.route,

  // 1. Force GoRouter to refresh routes every time the Firebase Auth State changes
  refreshListenable: GoRouterRefreshStream(_authService.authStateChanges()),

  // 2. Navigation Guard Daemon (Decides if user can access the target route)
  redirect: (BuildContext context, GoRouterState state) {
    final bool isLoggedIn = _authService.currentUser != null;
    final bool isGoingToLogin = state.matchedLocation == LoginScreen.route;

    // Guard Rule A: If not logged in, user is strictly locked into LoginScreen
    if (!isLoggedIn) {
      return LoginScreen.route;
    }

    // Guard Rule B: If already logged in and tries to access Login, bounce to Home
    if (isLoggedIn && isGoingToLogin) {
      return LoadingScreen.route;
    }

    // No redirection needed, let the user proceed
    return null;
  },

  routes: [
    GoRoute(
      path: LoginScreen.route,
      builder: (_, state) => const LoginScreen(),
    ),
    GoRoute(
      path: MainNavigationWrapper.route,
      builder: (_, state) => const MainNavigationWrapper(),
    ),
    GoRoute(
      path: LoadingScreen.route,
      builder: (_, state) => const LoadingScreen(),
    ),
    GoRoute(
      path: ErrorScreen.route,
      builder: (_, state) => ErrorScreen(exception: state.extra as StackMoneyException),
    ),
    GoRoute(
      path: PlanEditScreen.route,
      builder: (_, state) => PlanEditScreen(plan: state.extra as SalaryPlan),
    ),
    GoRoute(
      path: PersonalCfoScreen.route,
      builder: (_, state) => PersonalCfoScreen(),
    ),
  ],
);

/// Utility class to bridge Dart Streams into standard Flutter ChangeNotifier systems.
/// This allows GoRouter to listen directly to Firebase Authentication mutations.
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
