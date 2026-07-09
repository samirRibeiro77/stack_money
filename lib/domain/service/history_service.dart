import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/data/repository/firebase_history_repository.dart';

class HistoryManagementService {
  final FirebaseHistoryRepository _repository = FirebaseHistoryRepository();

  Future<List<History>> fetch() async {
    final historyList = await _repository.fetch();
    return historyList;
  }

  Future<List<Transaction>> fetchLastSprintValues() async {
    return await _repository.fetchLastSprintValues();
  }
}