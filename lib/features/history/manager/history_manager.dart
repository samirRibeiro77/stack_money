import 'package:flutter/foundation.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/domain/service/history_service.dart';

class HistoryManager {
  List<History> _consolidatedDays = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _hasError = ValueNotifier(false);

  ValueListenable<bool> get isLoading => _isLoading;

  ValueListenable<bool> get hasError => _hasError;

  List<History> get logs => _consolidatedDays;

  Future<void> loadFirebaseHistoryData() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      // Puxa a lista de snapshots consolidados por data (Documentos do Firebase)
      final logs = await HistoryManagementService().fetch();

      _consolidatedDays = logs.reversed.toList();
      _isLoading.value = false;
    } catch (e) {
      print('DEBUG_SYSTEM [HistoryScreen]: Mismatch structure fail -> $e');
      _isLoading.value = false;
      _hasError.value = true;
    }
  }
}
