import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';

class SecurityProvider extends InheritedNotifier<ValueNotifier<bool>> {
  const SecurityProvider({
    super.key,
    required super.notifier,
    required super.child,
  });

  static final LocalAuthentication _auth = LocalAuthentication();

  static bool isSecureOf(BuildContext context) {
    final inherited = context.dependOnInheritedWidgetOfExactType<SecurityProvider>();
    return inherited?.notifier?.value ?? false;
  }

  static Future<void> toggleOf(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final inherited = context.dependOnInheritedWidgetOfExactType<SecurityProvider>();
    if (inherited?.notifier == null) return;

    final ValueNotifier<bool> notifier = inherited!.notifier!;

    if (notifier.value == false) {
      notifier.value = true;
      return;
    }

    try {
      final bool canAuthenticate = await _auth.canCheckBiometrics || await _auth.isDeviceSupported();

      if (!canAuthenticate) {
        notifier.value = false;
        return;
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: l10n.securityBiometricReason,
        biometricOnly: false,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        notifier.value = false;
      }
    } on LocalAuthException catch (e) {
      debugPrint('Erro de autenticação local (v3): ${e.code} - ${e.description}');
    } catch (e) {
      debugPrint('Erro genérico: $e');
    }
  }
}
