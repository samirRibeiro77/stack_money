import 'package:flutter/foundation.dart';

class SmLogger {
  const SmLogger._();

  /// 🔵 LOG DE DEBUG: Informações internas de desenvolvimento técnico
  static void debug(String message) {
    if (kDebugMode) {
      print('🔵 [DEBUG] $message');
    }
  }

  /// 🟢 LOG DE INFO: Handshakes de API de sucesso e transições de estado
  static void info(String message) {
    if (kDebugMode) {
      print('🟢 [INFO] $message');
    }
  }

  /// 🟡 LOG DE WARNING: Comportamentos inesperados mas não fatais
  static void warning(String message) {
    if (kDebugMode) {
      print('🟡 [WARN] $message');
    }
  }

  /// 🔴 LOG DE ERROR: Falhas operacionais críticas com limpeza de StackTrace
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      print('🔴 [ERROR] $message');
      if (error != null) print('   ⚠️ Details: $error');
      if (stackTrace != null) {
        print('   🛰️ StackTrace:');
        // Limpa o StackTrace para mostrar apenas o topo relevante do seu código
        final lines = stackTrace.toString().split('\n');
        final localLines = lines.where((line) => line.contains('package:stack_money')).take(3);
        for (var line in localLines) {
          print('     -> ${line.trim()}');
        }
      }
    }
  }
}