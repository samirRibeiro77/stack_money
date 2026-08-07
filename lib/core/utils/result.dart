import 'package:stack_money/core/exceptions/stack_money_exception.dart';

sealed class Result<T> {
  bool get isSuccess => this is Success<T>;

  T getOrThrow() {
    return switch (this) {
      Success(data: final value) => value,
      Failure(exception: final error) => throw error,
    };
  }
}

class Success<T> extends Result<T> {
  final T data;

  Success(this.data);
}

class Failure<T> extends Result<T> {
  final StackMoneyException exception;

  Failure(this.exception);
}
