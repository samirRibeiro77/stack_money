import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/utils/sm_logger.dart';

class StackMoneyException implements Exception {
  final String message;
  final ExceptionScope scope;
  final Exception? exception;
  final StackTrace? stackTrace;
  final Map<String, Object?>? payload;
  late final String _errorMessage;

  StackMoneyException({
    required this.message,
    required this.scope,
    this.exception,
    this.stackTrace,
    this.payload,
  }) {
    _errorMessage = SmLogger.error(
      '[${scope.name.toUpperCase()}] $message',
      payload: payload,
      exception: exception,
      stackTrace: stackTrace,
    );
  }

  @override
  String toString() => _errorMessage;
}
