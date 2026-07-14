import 'package:flutter/foundation.dart';
import 'package:stack_money/core/utils/log_level.dart';

class SmLogger {
  const SmLogger._();

  /// Default message format
  static const _message = '{icon} {level} {place} {message}';

  /// Print message if in debug mode
  static void _logMessage(LogLevel level, String message) {
    final place = _getCallerInfo() ?? '';
    String log = _message
        .replaceAll('{icon}', level.emoji)
        .replaceAll('{level}', '[${level.level}]')
        .replaceAll('{place}', place)
        .replaceAll('{message}', message);

    if (kDebugMode) {
      debugPrint(log);
    }
  }

  /// Class and Method
  static String? _getCallerInfo() {
    if (!kDebugMode) return null;

    final stackLines = StackTrace.current.toString().split('\n');

    if (stackLines.length > 2) {
      final targetLine = stackLines[2];
      final match = RegExp(r'#\d+\s+([^\s]+)').firstMatch(targetLine);

      if (match != null && match.groupCount >= 1) {
        final member = match.group(1)!;
        return "[${member.replaceAll('.<anonymous closure>', '')}]";
      }
    }

    return null;
  }

  /// DEBUG LOG: Internal and developer info
  static void debug(String message) {
    _logMessage(LogLevel.debug, message);
  }

  /// INFO LOG: Handshake, success and state
  static void info(String message) {
    _logMessage(LogLevel.info, message);
  }

  /// WARNING LOG: Non-fatal errors
  static void warning(String message) {
    _logMessage(LogLevel.warning, message);
  }

  /// ERROR LOG: Fatal errors with more details
  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      final buffer = StringBuffer();
      buffer.writeln(message);

      if (error != null) {
        buffer.writeln('   ⚠️ Details: $error');
      }

      if (stackTrace != null) {
        buffer.writeln('   🛰️ StackTrace:');
        final lines = stackTrace.toString().split('\n');
        final localLines = lines
            .where((line) => line.contains('package:stack_money'))
            .take(5);
        for (var line in localLines) {
          buffer.writeln('     -> ${line.trim()}');
        }
      }

      final fullMessage = buffer.toString().trimRight();
      _logMessage(LogLevel.error, fullMessage);
    }
  }
}
