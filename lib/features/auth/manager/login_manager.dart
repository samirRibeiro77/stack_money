import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/domain/service/auth_service.dart';

/// State and business logic coordinator for the Authentication feature.
/// Uses ValueNotifier to expose lightweight reactive states to the UI.
class LoginManager {
  final AuthService _authService = AuthService();

  /// Encapsulated state notifier to tracking async operations
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  /// Public read-only view of the loading state for UI consumption.
  ValueListenable<bool> get isLoading => _isLoadingNotifier;

  /// Dispatches the Google Sign-In pipeline and safely manages loading states.
  Future<User?> loginWithGoogle() async {
    try {
      // Turn on the HUD loading indicator
      _isLoadingNotifier.value = true;

      final User? user = await _authService.signInWithGoogle();
      return user;
    } finally {
      // Guarantees the loader turns off even if an exception occurs
      _isLoadingNotifier.value = false;
    }
  }

  /// Cleans up state listeners when the manager lifecycle ends.
  void dispose() {
    _isLoadingNotifier.dispose();
  }
}