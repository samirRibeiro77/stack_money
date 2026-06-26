import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/chart_filter.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_filter_bar.dart';

class DashboardBucketCard extends StatefulWidget {
  final Bucket parameter;
  final List<History> historyList;
  final bool isExpanded;
  final VoidCallback onHeaderTap;

  const DashboardBucketCard({
    super.key,
    required this.parameter,
    required this.historyList,
    required this.isExpanded,
    required this.onHeaderTap,
  });

  @override
  State<DashboardBucketCard> createState() => _DashboardBucketCardState();
}

class _DashboardBucketCardState extends State<DashboardBucketCard> {
  ChartFilterState _chartFilter = const ChartFilterState(
    filter: ChartFilter.threeMonths,
  );

  double _getBucketValueAt(History history) {
    final transaction =
        history.transactions[widget.parameter.id.replaceAll(' ', '')];
    return transaction?.actualValue ?? 0.0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.historyList.isEmpty) return const SizedBox();

    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    final latestHistory = widget.historyList.last;
    final firstDate = widget.historyList.first.date;
    final double currentBalance = _getBucketValueAt(latestHistory);
    final bool isUnderclock = currentBalance < widget.parameter.minValue;

    final Color healthColor = isUnderclock
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.x8),
      child: GestureDetector(
        onTap: !isSecureActive ? widget.onHeaderTap : null,
        child: SmCard(
          shadowColor: healthColor,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SecurityText(
                        StackMoneyString.formatTitle(widget.parameter.name),
                        style: textTheme.titleSmall,
                        type: SecurityType.systemLocked,
                      ),
                      const SizedBox(height: AppSizes.sizedBoxSmall),
                      Row(
                        children: [
                          Text(l10n.allocation, style: textTheme.labelSmall),
                          SecurityText(
                            StackMoneyString.formatPercentage(
                              (currentBalance / latestHistory.total) * 100,
                              decimal: 2,
                            ),
                            style: textTheme.labelSmall,
                            activeColor: StackMoneyTheme.mutedGrey,
                          ),
                          if (!isSecureActive)
                            Text(
                              l10n.percentSignal,
                              style: textTheme.labelSmall,
                            ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      SecurityText(
                        StackMoneyString.formatMoney(
                          currentBalance,
                          symbol: true,
                        ),
                        type: SecurityType.mask,
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        activeColor: healthColor,
                      ),
                      const SizedBox(height: AppSizes.sizedBoxSmall),
                      Row(
                        children: [
                          Text(l10n.min, style: textTheme.labelSmall),
                          SecurityText(
                            StackMoneyString.formatMoney(
                              widget.parameter.minValue,
                              symbol: true,
                            ),
                            style: textTheme.labelSmall,
                            activeColor: StackMoneyTheme.mutedGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Miolo expandido guiado de forma reativa por valor invertido (!isSecureActive)
              if (widget.isExpanded && !isSecureActive) ...[
                const SizedBox(height: AppSizes.sizedBoxMedium),
                const Divider(),
                const SizedBox(height: AppSizes.sizedBoxMedium),
                _buildMiniChart(healthColor),
                const SizedBox(height: AppSizes.sizedBoxMedium),
                TelemetryFilterBar(
                  currentState: _chartFilter,
                  isEnabled: true,
                  firstDate: firstDate,
                  chipColor: healthColor,
                  onFilterChanged: (newState) {
                    setState(() {
                      _chartFilter = newState;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniChart(Color activeColor) {
    if (widget.historyList.isEmpty) return const SizedBox.shrink();

    final latestDate = widget.historyList.last.date;

    List<History> filteredHistory = widget.historyList.where((h) {
      if (_chartFilter.filter == ChartFilter.custom && _chartFilter.hasDates) {
        return h.date.isAfter(_chartFilter.start!) &&
            h.date.isBefore(_chartFilter.end!);
      }
      return latestDate.difference(h.date).inDays <= _chartFilter.filter.days;
    }).toList();

    if (filteredHistory.isEmpty) filteredHistory = [widget.historyList.last];

    List<double> values = filteredHistory
        .map((h) => _getBucketValueAt(h))
        .toList();
    values.add(widget.parameter.minValue);

    double absoluteMin = values.reduce((a, b) => a < b ? a : b);
    double absoluteMax = values.reduce((a, b) => a > b ? a : b);

    double delta = absoluteMax - absoluteMin;
    if (delta == 0) delta = widget.parameter.minValue.abs() * 0.2;
    if (delta == 0) delta = 100.0;

    double computedMinY = absoluteMin - (delta * 0.1);
    double computedMaxY = absoluteMax + (delta * 0.1);

    List<FlSpot> spots = [];
    for (int i = 0; i < filteredHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), _getBucketValueAt(filteredHistory[i])));
    }

    return SizedBox(
      height: 110,
      child: LineChart(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        LineChartData(
          minY: computedMinY,
          maxY: computedMaxY,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => StackMoneyTheme.surface,
              tooltipBorder: BorderSide(color: activeColor, width: 1),
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              tooltipRoundedRadius: 2,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final deltaValue = spot.y - widget.parameter.minValue;
                  return LineTooltipItem(
                    StackMoneyString.formatMoney(spot.y),
                    TextStyle(
                      color: deltaValue >= 0
                          ? StackMoneyTheme.cyanNeon
                          : StackMoneyTheme.magentaNeon,
                      fontFamily: 'Orbitron',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
          ),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: widget.parameter.minValue,
                color: Colors.white.withValues(alpha: 0.15),
                strokeWidth: 1,
                dashArray: [4, 4],
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: activeColor,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    activeColor.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
