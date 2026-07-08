import 'package:stack_money/core/utils/sm_logger.dart';

enum ExceptionScope { database, auth, business, network }

class StackMoneyException implements Exception {
  final String message;
  final String where;
  final ExceptionScope scope;
  final StackTrace? stackTrace;
  final Map<String, Object?>? payload;

  StackMoneyException({
    required this.message,
    required this.where,
    required this.scope,
    this.stackTrace,
    this.payload,
  }) {
    SmLogger.error(
      '[$scope] $message',
      where: where,
      error: payload != null ? 'Payload: ${payload.toString()}' : null,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => 'StackMoneyException [$scope]: $message';
}