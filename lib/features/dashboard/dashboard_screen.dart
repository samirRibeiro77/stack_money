import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/sm_gravity_swop_list.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/features/dashboard/manager/dashboard_manager.dart';
import 'package:stack_money/features/dashboard/widgets/dashboard_sort_bottom_sheet.dart';
import 'package:stack_money/features/dashboard/widgets/dashboard_bucket_card.dart';
import 'package:stack_money/features/dashboard/widgets/patrimonial_hud.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_filter_bar.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_line_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key = const ValueKey(route)});

  static const route = '/dashboard';

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _manager = DashboardManager();

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return ValueListenableBuilder(
      valueListenable: AppCoordinator.instance.history,
      builder: (_, historyList, _) {
        historyList.sort((a, b) => a.date.compareTo(b.date));

        final latestAudit = historyList.lastOrNull;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PatrimonialHud(
              totalAmount: latestAudit?.total ?? 0,
              liquidityAmount: latestAudit?.immediateLiquidityTotal ?? 0,
            ),
            const SizedBox(height: AppSizes.x10),
            ValueListenableBuilder(
              valueListenable: _manager.chartFilterNotifier,
              builder: (_, currentFilter, _) {
                return SmCard(
                  title: l10n.telemetryStream,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 220,
                        child: TelemetryLineChart(
                          rawHistoryData: historyList,
                          filterState: currentFilter,
                        ),
                      ),
                      const SizedBox(height: AppSizes.sizedBoxMedium),
                      const Divider(height: 1),
                      const SizedBox(height: AppSizes.sizedBoxMedium),
                      TelemetryFilterBar(
                        currentState: currentFilter,
                        firstDate:
                            historyList.firstOrNull?.date.toDate() ??
                            DateTime.now(),
                        onFilterChanged: _manager.updateChartFilter,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.x12),
            ValueListenableBuilder(
              valueListenable: AppCoordinator.instance.buckets,
              builder: (_, buckets, _) {
                return ValueListenableBuilder(
                  valueListenable: AppCoordinator.instance.user,
                  builder: (_, user, _) {
                    final activeSort = user.preferences.currentFilter;
                    _manager.updateSortFilter(buckets, activeSort);

                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: ExpandableHeader(
                                title: l10n.allocationBuckets,
                                toggle: _manager.toggleAllBuckets,
                                validation: _manager.masterExpandState,
                              ),
                            ),
                            if (!isSecureActive)
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                transitionBuilder:
                                    (
                                      Widget child,
                                      Animation<double> animation,
                                    ) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: RotationTransition(
                                          turns: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                child: IconButton(
                                  key: ValueKey<DashboardSortFilter>(
                                    activeSort,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  splashRadius: AppSizes.x6,
                                  icon: Icon(
                                    activeSort.icon,
                                    color: StackMoneyTheme.cyanNeon,
                                    size: AppSizes.x10,
                                  ),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      useRootNavigator: true,
                                      backgroundColor: Colors.transparent,
                                      elevation: 1,
                                      builder: (_) => DashboardSortBottomSheet(
                                        currentSort: activeSort,
                                        onFilterSelected: (filter) => _manager
                                            .updateSortFilter(buckets, filter),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSizes.sizedBoxMedium),
                        ValueListenableBuilder(
                          valueListenable: _manager.expandedIdsNotifier,
                          builder: (_, expandedIds, _) {
                            return SmGravitySwopList(
                              sortKey: activeSort,
                              children: List.generate(buckets.length, (index) {
                                final param = buckets[index];
                                final isCardExpanded = expandedIds.contains(
                                  param.id,
                                );

                                return DashboardBucketCard(
                                  key: ValueKey(param.id),
                                  parameter: param,
                                  historyList: historyList,
                                  isExpanded: isCardExpanded,
                                  onHeaderTap: () =>
                                      _manager.toggleBucketExpansion(param.id),
                                );
                              }),
                            );
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }
}
