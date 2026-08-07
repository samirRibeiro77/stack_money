import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/firebase_history_repository.dart';

class HistoryManagementService {
  final FirebaseHistoryRepository _repository = FirebaseHistoryRepository();

  Future<Result<List<History>>> fetch() async {
    try {
      final historyList = await _repository.fetch();
      return Success(historyList);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching history',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<History>> fetchLatest() async {
    try {
      final latestHistory = await _repository.fetchLatest() ?? History.withValues();
      return Success(latestHistory);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching latest history',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Future<Result<List<Transaction>>> fetchLastSprintValues() async {
    try {
      final history = await _repository.fetchLatest();
      return Success(history?.transactions ?? []);
    } on StackMoneyException catch (e) {
      return Failure(e);
    } catch (e, stack) {
      return Failure(
        StackMoneyException(
          message: 'Error fetching last sprint values',
          scope: ExceptionScope.service,
          exception: e as Exception,
          stackTrace: stack,
        ),
      );
    }
  }

  Stream<List<History>> watch() {
    return _repository.watch();
  }
}
