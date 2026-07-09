import 'package:flutter/foundation.dart';

class SmLogger {
  const SmLogger._();

  /// 🔵 LOG DE DEBUG: Informações internas de desenvolvimento técnico
  static void debug(String message, {required String where}) {
    _logMessage('🐛 [DEBUG] [$where] $message');
  }

  /// 🟢 LOG DE INFO: Handshakes de API de sucesso e transições de estado
  static void info(String message, {required String where}) {
    _logMessage('💡 [INFO] [$where] $message');
  }

  /// 🟡 LOG DE WARNING: Comportamentos inesperados mas não fatais
  static void warning(String message, {required String where}) {
    _logMessage('⚠️ [WARN] [$where] $message');
  }

  /// 🔴 LOG DE ERROR: Falhas operacionais críticas com limpeza de StackTrace
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

  static void _logMessage(String message) {
    final dateTime = DateTime.now().toIso8601String();
    if (kDebugMode) {
      debugPrint('$dateTime - $message');
    }
  }
}