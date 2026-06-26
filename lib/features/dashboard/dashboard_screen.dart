import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/features/dashboard/manager/dashboard_manager.dart';
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
  void initState() {
    super.initState();
    _manager.loadFirebaseDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.isLoading,
      builder: (_, isLoading, _) {
        if (isLoading) {
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

        return ValueListenableBuilder<bool>(
          valueListenable: _manager.hasError,
          builder: (_, hasError, _) {
            if (hasError || _manager.historyTimeline.isEmpty) {
              return _buildErrorState(l10n, textTheme);
            }

            // Injeta a fiação reativa tripla para reconstruir o painel sob demanda
            return ValueListenableBuilder<List<Bucket>>(
              valueListenable: _manager.parametersNotifier,
              builder: (context, paramList, child) {
                paramList.sort((a, b) => a.name.compareTo(b.name));

                return ValueListenableBuilder<List<History>>(
                  valueListenable: _manager.historyTimelineNotifier,
                  builder: (context, historyList, child) {
                    return ValueListenableBuilder<Set<String>>(
                      valueListenable: _manager.expandedIdsNotifier,
                      builder: (context, expandedIds, child) {
                        return ValueListenableBuilder<ChartFilterState>(
                          valueListenable: _manager.chartFilterNotifier,
                          builder: (context, currentFilter, _) {
                            return _buildBodyContent(
                              l10n,
                              textTheme,
                              paramList,
                              historyList,
                              expandedIds,
                              currentFilter,
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
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

  Widget _buildBodyContent(
    AppLocalizations l10n,
    TextTheme textTheme,
    List<Bucket> paramList,
    List<History> historyList,
    Set<String> expandedIds,
    ChartFilterState currentFilter,
  ) {
    final isSecureActive = SecurityProvider.isSecureOf(context);
    final isVisible =
        !isSecureActive; // Lógica inversa unificada: visível se segurança biométrica estiver aberta

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

        // Painel Telemetria com Gráfico Principal
        SmCard(
          title: l10n.telemetryStream,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 220,
                child: TelemetryLineChart(
                  rawHistoryData: historyList,
                  filterState: currentFilter,
                  isSystemVisible: isVisible,
                ),
              ),
              const SizedBox(height: AppSizes.sizedBoxMedium),
              const Divider(height: 1),
              const SizedBox(height: AppSizes.sizedBoxMedium),
              TelemetryFilterBar(
                currentState: currentFilter,
                isEnabled: isVisible,
                firstDate: historyList.first.date,
                onFilterChanged: _manager.updateChartFilter,
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSizes.x12),

        // Cabeçalho da listagem de alocação de Potes
        ExpandableHeader(
          title: l10n.allocationBuckets,
          toggle: _manager.toggleAllBuckets,
          validation: _manager.masterExpandState,
          activeIcon: Icons.unfold_more,
          inactiveIcon: Icons.unfold_less,
        ),
        const SizedBox(height: AppSizes.sizedBoxMedium),

        // Listagem dos Potes Convertidos em Componentes Dedicados do Dashboard
        ...List.generate(paramList.length, (index) {
          final param = paramList[index];
          final isCardExpanded = expandedIds.contains(param.id);

          return DashboardBucketCard(
            key: ValueKey(param.id),
            parameter: param,
            historyList: historyList,
            isExpanded: isCardExpanded,
            onHeaderTap: () => _manager.toggleBucketExpansion(param.id),
          );
        }),
      ],
    );
  }
}
