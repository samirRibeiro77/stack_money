import 'package:stack_money/core/exceptions/stack_money_exception.dart';

sealed class Result<T> {}

class Success<T> extends Result<T> {
  final T data;
  Success(this.data);
}

class Failure<T> extends Result<T> {
  final StackMoneyException exception;
  Failure(this.exception);
}