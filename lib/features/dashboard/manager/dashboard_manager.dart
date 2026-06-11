import 'package:flutter/foundation.dart';
import 'package:stack_money/data/enum/chart_filter.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/parameter_service.dart';

class DashboardManager {
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _hasError = ValueNotifier(false);
  final ValueNotifier<bool> _masterExpandState = ValueNotifier(true);

  final ValueNotifier<List<Bucket>> _realParameters = ValueNotifier([]);
  final ValueNotifier<List<History>> _realHistoryTimeline = ValueNotifier([]);
  final ValueNotifier<Set<String>> _expandedBucketIds = ValueNotifier({});
  final ValueNotifier<ChartFilterState> _chartFilter = ValueNotifier(
    const ChartFilterState(filter: ChartFilter.threeMonths),
  );

  ValueListenable<bool> get isLoading => _isLoading;
  ValueListenable<bool> get hasError => _hasError;
  ValueListenable<bool> get masterExpandState => _masterExpandState;

  ValueListenable<List<Bucket>> get parametersNotifier => _realParameters;
  ValueListenable<List<History>> get historyTimelineNotifier => _realHistoryTimeline;
  ValueListenable<Set<String>> get expandedIdsNotifier => _expandedBucketIds;
  ValueListenable<ChartFilterState> get chartFilterNotifier => _chartFilter;

  List<Bucket> get parameters => _realParameters.value;
  List<History> get historyTimeline => _realHistoryTimeline.value;
  ChartFilterState get chartFilter => _chartFilter.value;

  Future<void> loadFirebaseDashboardData() async {
    try {
      _isLoading.value = true;
      _hasError.value = false;

      final results = await Future.wait([
        ParameterManagementService().getActiveParameters(),
        HistoryManagementService().getConsolidatedHistory(),
      ]);

      _realParameters.value = results[0] as List<Bucket>;
      _realHistoryTimeline.value = results[1] as List<History>;

      _isLoading.value = false;
    } catch (e) {
      print('DEBUG_SYSTEM [DashboardManager]: Critical fail -> $e');
      _isLoading.value = false;
      _hasError.value = true;
    }
  }

  void updateChartFilter(ChartFilterState newState) {
    _chartFilter.value = newState;
  }

  void toggleBucketExpansion(String id) {
    final currentSet = Set<String>.from(_expandedBucketIds.value);
    if (currentSet.contains(id)) {
      currentSet.remove(id);
    } else {
      currentSet.add(id);
    }
    _expandedBucketIds.value = currentSet;
  }

  void toggleAllBuckets() {
    if (_masterExpandState.value) {
      _expandedBucketIds.value = _realParameters.value.map((b) => b.id).toSet();
    } else {
      _expandedBucketIds.value = {};
    }
    _masterExpandState.value = !_masterExpandState.value;
  }
}