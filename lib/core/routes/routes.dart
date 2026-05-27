import 'package:go_router/go_router.dart';
import 'package:stack_money/features/auth/login_screen.dart';
import 'package:stack_money/features/home/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: LoginScreen.route,
  routes: [
    GoRoute(path: LoginScreen.route, builder: (_, state) => const LoginScreen()),
    GoRoute(path: HomeScreen.route, builder: (_, state) => const HomeScreen())
  ]
);