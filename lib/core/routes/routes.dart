import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/domain/service/auth_service.dart';
import 'package:stack_money/features/auth/login_screen.dart';
import 'package:stack_money/features/home/home_screen.dart';

final AuthService _authService = AuthService();

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
      return HomeScreen.route;
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
      path: HomeScreen.route,
      builder: (_, state) => const HomeScreen(),
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