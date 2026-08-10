import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:stack_money/core/utils/log_level.dart';

class SmLogger {
  const SmLogger._();

  /// Static values
  static const _unknown = 'Unknown';
  static const _prefix = 'SJR77';

  /// Print message if in debug mode
  static void _logMessage(LogLevel level, String message) {
    final logBuffer = <String>[];

    logBuffer.add(level.message);
    logBuffer.add(message);

    if (kDebugMode) {
      logBuffer.insert(0, _prefix);
      logBuffer.insert(2, '[${_getCallerInfo()}]');
      debugPrint(logBuffer.join(' ').trim());
    }

    // TODO: Log on firebase
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
  static void debug(String message, {required Map<String, Object?> payload}) {
    final logMessage = StringBuffer();
    logMessage.writeln(message);

    if (payload.isNotEmpty) {
      try {
        final encoder = const JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(payload);

        logMessage.writeln('  📦 [PAYLOAD]:');
        for (final line in prettyJson.split('\n')) {
          logMessage.writeln('     $line');
        }
      } catch (_) {
        logMessage.write('  📦 [PAYLOAD_RAW]: $payload');
      }
    }

    _logMessage(LogLevel.debug, logMessage.toString());
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
  static String error(
    String message, {
    Object? payload,
    Exception? exception,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(message);

    /// Payload
    if (payload != null) {
      buffer.writeln('  📦 [PAYLOAD]: $payload');
    }

    /// Exception
    if (exception != null) {
      buffer.writeln('  🚨 [EXCEPTION]:');
      final exceptionLines = exception.toString().split('\n');
      for (var line in exceptionLines) {
        if (line.trim().isNotEmpty) {
          buffer.writeln('     ☣️ ${line.trim()}');
        }
      }
    }

    /// StackTrace
    if (stackTrace != null) {
      buffer.writeln('  🛰️ [STACK_TRACE]:');
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
    return fullMessage;
  }
}
