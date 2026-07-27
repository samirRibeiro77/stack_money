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
    return await _repository.fetchLatest();
  }

  Future<List<Transaction>> fetchLastSprintValues() async {
    final history = await _repository.fetchLatest();
    return history.transactions;
  }

  Stream<List<History>> watch() {
    return _repository.watch();
  }
}
