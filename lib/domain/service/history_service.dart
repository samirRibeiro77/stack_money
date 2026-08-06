import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/firebase_history_repository.dart';

class HistoryManagementService {
  final FirebaseHistoryRepository _repository = FirebaseHistoryRepository();

  Future<List<History>> fetch() async {
    final historyList = await _repository.fetch();
    return historyList;
  }

  Future<History> fetchLatest() async {
    return await _repository.fetchLatest() ?? History.withValues();
  }

  Future<List<Transaction>> fetchLastSprintValues() async {
    try {
      final history = await _repository.fetchLatest();
      return history?.transactions ?? [];
    } catch (e, stack) {
      StackMoneyException(
        message: 'Error fetching last sprint values',
        scope: ExceptionScope.business,
        exception: e as Exception,
        stackTrace: stack,
      );

      return [];
    }
  }

  Stream<List<History>> watch() {
    return _repository.watch();
  }
}
