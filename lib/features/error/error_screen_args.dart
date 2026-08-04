import 'dart:ui';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';

class ErrorScreenArgs {
  final StackMoneyException exception;
  final VoidCallback? retryFunction;

  ErrorScreenArgs({required this.exception, this.retryFunction});
}