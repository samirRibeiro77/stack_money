import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/sm_gravity_swop_list.dart';
import 'package:stack_money/data/enum/dashboard_sort_filter.dart';
import 'package:stack_money/features/dashboard/manager/dashboard_manager.dart';
import 'package:stack_money/features/dashboard/manager/data_pipeline_manager.dart';
import 'package:stack_money/features/dashboard/widgets/dashboard_sort_bottom_sheet.dart'; // 🔥 Novo Import
import 'package:stack_money/features/dashboard/widgets/dashboard_bucket_card.dart';
import 'package:stack_money/features/dashboard/widgets/glassmorphic_dev_overlay.dart';
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
  void initState() {
    super.initState();
    _manager.loadFirebaseDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        GlassmorphicDevOverlay(
          onTriggerPipeline: () =>
              DataPipelineManager().runSequentialAssetSeeder(),
        ),
        const SizedBox(height: AppSizes.x10),
        ValueListenableBuilder<bool>(
          valueListenable: _manager.isLoading,
          builder: (_, isLoading, _) {
            if (isLoading) {
              return _buildLoadingState();
            }

            return ValueListenableBuilder<bool>(
              valueListenable: _manager.hasError,
              builder: (_, hasError, _) {
                if (hasError || _manager.historyTimeline.isEmpty) {
                  return _buildErrorState(l10n, textTheme);
                }

                return _buildBodyContent(l10n);
              },
            );
          },
        )
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 400,
      child: Center(
        child: CircularProgressIndicator(
          color: StackMoneyTheme.cyanNeon,
          backgroundColor: StackMoneyTheme.surface,
          strokeWidth: 3,
        ),
      ),
    );
  }

  Widget _buildErrorState(AppLocalizations l10n, TextTheme textTheme) {
    return SizedBox(
      height: 300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.gpp_maybe_outlined,
              color: StackMoneyTheme.magentaNeon,
              size: AppSizes.x24,
            ),
            const SizedBox(height: AppSizes.sizedBoxLarge),
            Text(
              StackMoneyString.formatTitle(l10n.systemLinkFailed),
              style: textTheme.headlineMedium?.copyWith(
                color: StackMoneyTheme.magentaNeon,
              ),
            ),
            const SizedBox(height: AppSizes.sizedBoxSmall),
            TextButton(
              onPressed: _manager.loadFirebaseDashboardData,
              child: Text(
                StackMoneyString.formatTitle(l10n.retryHandshake),
                style: textTheme.titleMedium?.copyWith(
                  color: StackMoneyTheme.cyanNeon,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(AppLocalizations l10n) {
    return ValueListenableBuilder(
      valueListenable: _manager.historyTimelineNotifier,
      builder: (_, historyList, _) {
        final latestAudit = historyList.last;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            PatrimonialHud(
              totalAmount: latestAudit.total,
              liquidityAmount: latestAudit.immediateLiquidityTotal,
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
                        firstDate: historyList.first.date.toDate(),
                        onFilterChanged: _manager.updateChartFilter,
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: AppSizes.x12),
            ValueListenableBuilder(
              valueListenable: _manager.sortFilterNotifier,
              builder: (_, activeSort, _) {
                final isSecureActive = SecurityProvider.isSecureOf(context);

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
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: RotationTransition(
                                      turns: animation,
                                      child: child,
                                    ),
                                  );
                                },
                            child: IconButton(
                              key: ValueKey<DashboardSortFilter>(activeSort),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              splashRadius: AppSizes.x6,
                              // Opção 1: Morphing Cyber-Icon ativo
                              icon: Icon(
                                activeSort.icon,
                                color: StackMoneyTheme.cyanNeon,
                                size: AppSizes.x10,
                              ),
                              // 🔥 MODIFICADO: Invocação direta e desacoplada do novo widget externo
                              onPressed: () {
                                showModalBottomSheet(
                                  context: context,
                                  useRootNavigator: true,
                                  backgroundColor: Colors.transparent,
                                  elevation: 1,
                                  builder: (_) => DashboardSortBottomSheet(
                                    currentSort: activeSort,
                                    onFilterSelected: _manager.updateSortFilter,
                                  ),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.sizedBoxMedium),
                    ValueListenableBuilder(
                      valueListenable: _manager.parametersNotifier,
                      builder: (_, bucketList, _) {
                        return ValueListenableBuilder(
                          valueListenable: _manager.expandedIdsNotifier,
                          builder: (_, expandedIds, _) {
                            return SmGravitySwopList(
                              sortKey: activeSort,
                              children: List.generate(bucketList.length, (
                                index,
                              ) {
                                final param = bucketList[index];
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
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ],
        );
      },
    );
  }
}
