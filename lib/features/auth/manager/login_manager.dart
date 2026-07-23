import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/domain/service/user_service.dart';

class LoginManager {
  final _userService = UserService();
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  ValueListenable<bool> get isLoading => _isLoadingNotifier;

  Future<User?> loginWithGoogle() async {
    try {
      _isLoadingNotifier.value = true;

      final User? user = await _userService.signInWithGoogle();
      if (user == null) {
        throw Exception('Something went wrong capturing the user logged');
      }

      return user;
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to login',
        scope: ExceptionScope.auth,
        payload: {'exception': e},
        stackTrace: stack,
      );
    } finally {
      _isLoadingNotifier.value = false;
    }

    return null;
  }

  void dispose() {
    _isLoadingNotifier.dispose();
  }
}
