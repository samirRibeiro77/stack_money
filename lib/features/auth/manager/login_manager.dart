import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/domain/service/user_service.dart';

class LoginManager {
  final _userService = UserService();
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier<bool>(false);

  ValueListenable<bool> get isLoading => _isLoadingNotifier;

  Future<void> loginWithGoogle(BuildContext context) async {
    try {
      _isLoadingNotifier.value = true;
      (await _userService.signInWithGoogle()).getOrThrow();
    } catch (_) {
      if (context.mounted) {
        _showError(context);
      }
    } finally {
      _isLoadingNotifier.value = false;
    }
  }

  void _showError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SmSnackBar(
      message: l10n.failedToSignIn,
      type: SnackBarType.error,
      action: SnackBarAction(
        label: l10n.retry,
        onPressed: () => loginWithGoogle(context),
      ),
    ).show(context);
  }

  void dispose() {
    _isLoadingNotifier.dispose();
  }
}
