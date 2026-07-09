import 'package:flutter/foundation.dart';

class SmLogger {
  const SmLogger._();

  /// DEBUG LOG: Internal and developer info
  static void debug(String message, {required String where}) {
    _logMessage('🐛 [DEBUG] [$where] $message');
  }

  /// INFO LOG: Handshake, success and state
  static void info(String message, {required String where}) {
    _logMessage('💡 [INFO] [$where] $message');
  }

  /// WARNING LOG: Non-fatal errors
  static void warning(String message, {required String where}) {
    _logMessage('⚠️ [WARN] [$where] $message');
  }

  /// ERROR LOG: Fatal errors with more details
  static void error(String message, {required String where, Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln('🚨 [ERROR] [$where] $message');

      if (error != null) {
        buffer.writeln('   ⚠️ Details: $error');
      }

      if (stackTrace != null) {
        buffer.writeln('   🛰️ StackTrace:');
        final lines = stackTrace.toString().split('\n');
        final localLines = lines.where((line) => line.contains('package:stack_money')).take(3);
        for (var line in localLines) {
          buffer.writeln('     -> ${line.trim()}');
        }
      }

      final fullMessage = buffer.toString().trimRight();
      _logMessage(fullMessage);
    }
  }

  /// Method to log the message on developer console
  static void _logMessage(String message) {
    final dateTime = DateTime.now().toIso8601String();
    if (kDebugMode) {
      debugPrint('$dateTime - $message');
    }
  }
}