import 'package:stack_money/domain/data/models/history.dart';
import 'package:stack_money/domain/repository/firebase_history_repository.dart';

class HistoryManagementService {
  final FirebaseHistoryRepository _historyRepository = FirebaseHistoryRepository();

  Future<List<History>> getConsolidatedHistory() async {
    final historyList = await _historyRepository.fetchHistoryTimeline();

    // Como cada objeto 'History' interno já monta seu próprio mapa de 'Transaction'
    // através do factory History.fromJson, os dados já chegam consolidados por aqui!
    return historyList;
  }
}