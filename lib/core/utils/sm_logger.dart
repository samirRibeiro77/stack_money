import 'package:flutter/foundation.dart';
import 'package:stack_money/core/utils/log_level.dart';

class SmLogger {
  const SmLogger._();

  /// Static values
  static const _unknown = 'Unknown';
  static const _prefix = 'SJR77';

  /// Print message if in debug mode
  static void _logMessage(LogLevel level, String message) {
    final logBuffer = StringBuffer();
    
    if (_prefix.isNotEmpty) {
      logBuffer.write('[$_prefix] ');
    }

    logBuffer.write('${level.emoji} ${level.level} ');

    if (kDebugMode) {
      logBuffer.write('[${_getCallerInfo()}] ');
    }

    logBuffer.write(message);

    if (kDebugMode) {
      debugPrint(logBuffer.toString().trim());
    }
  }

  /// Class and Method
  static String _getCallerInfo() {
    if (!kDebugMode) return _unknown;

    final stackLines = StackTrace.current.toString().split('\n');

    if (stackLines.length > 3) {
      final targetLine = stackLines[3];
      final match = RegExp(r'#\d+\s+([^\s]+)').firstMatch(targetLine);

      if (match != null && match.groupCount >= 1) {
        final member = match.group(1)!;
        return member.replaceAll('.<anonymous closure>', '');
      }
    }

    return _unknown;
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
