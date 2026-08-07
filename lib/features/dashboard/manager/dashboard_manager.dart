import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/chart_filter.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/domain/service/user_service.dart';

class DashboardManager {
  final _userService = UserService();

  final _masterExpandState = ValueNotifier(true);
  final _expandedBucketIds = ValueNotifier(<String>{});
  final _sortFilter = ValueNotifier(DashboardSortFilter.position);
  final _chartFilter = ValueNotifier(
    const ChartFilterState(filter: ChartFilter.threeMonths),
  );

  DashboardManager() {
    final initialExpand =
        !AppCoordinator.instance.user.value.preferences.cardExpand;
    if (_masterExpandState.value != initialExpand) {
      toggleAllBuckets();
    }
  }

  ValueListenable<bool> get masterExpandState => _masterExpandState;

  ValueListenable<Set<String>> get expandedIdsNotifier => _expandedBucketIds;

  ValueListenable<ChartFilterState> get chartFilterNotifier => _chartFilter;

  ValueListenable<DashboardSortFilter> get sortFilterNotifier => _sortFilter;

  ChartFilterState get chartFilter => _chartFilter.value;

  DashboardSortFilter get activeSort => _sortFilter.value;

  void updateSortFilter(
    BuildContext context,
    List<Bucket> buckets,
    DashboardSortFilter newFilter,
  ) {
    SmLogger.debug(
      'Sorting filter',
      payload: {'old': _sortFilter.value, 'new': newFilter},
    );

    final latestHistory = AppCoordinator.instance.history.value.lastOrNull;

    buckets.sort((a, b) {
      final double valA =
          latestHistory?.transactions
              .where((t) => t.bucketId == a.id)
              .firstOrNull
              ?.actualValue ??
          0.0;
      final double valB =
          latestHistory?.transactions
              .where((t) => t.bucketId == b.id)
              .firstOrNull
              ?.actualValue ??
          0.0;

      switch (newFilter) {
        case DashboardSortFilter.position:
          return a.position.compareTo(b.position);
        case DashboardSortFilter.name:
          return a.name.compareTo(b.name);
        case DashboardSortFilter.currentValue:
          return valB.compareTo(valA);
        case DashboardSortFilter.minValue:
          return a.minValue.compareTo(b.minValue);
        case DashboardSortFilter.allocation:
          final double allocA = (valA / (latestHistory?.total ?? 1)) * 100;
          final double allocB = (valB / (latestHistory?.total ?? 1)) * 100;
          return allocB.compareTo(allocA);
      }
    });

    _userService.updateLastFilter(newFilter).then((result) {
      result.fold(
        onSuccess: (_) {
          _sortFilter.value = newFilter;
        },
        onFailure: (e) {
          if (context.mounted) {
            final l10n = AppLocalizations.of(context)!;
            SmSnackBar(
              message: l10n.failedUpdateLastFilter,
              type: SnackBarType.error,
            ).show(context);
          }
        },
      );
    });
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
      _expandedBucketIds.value = AppCoordinator.instance.buckets.value
          .map((b) => b.id)
          .toSet();
    } else {
      _expandedBucketIds.value = {};
    }
    _masterExpandState.value = !_masterExpandState.value;
  }

  void dispose() {
    _masterExpandState.dispose();
    _expandedBucketIds.dispose();
    _sortFilter.dispose();
    _chartFilter.dispose();
  }
}
