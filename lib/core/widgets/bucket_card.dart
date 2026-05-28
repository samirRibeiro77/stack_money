import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/domain/data/enum/chart_filter.dart';
import 'package:stack_money/domain/data/models/chart_filter_state.dart';
import 'package:stack_money/domain/data/models/history.dart';
import 'package:stack_money/domain/data/models/parameters.dart';
import 'package:stack_money/features/home/widgets/telemetry_filter_bar.dart';

class BucketCard extends StatefulWidget {
  final Parameter parameter;
  final List<History> historyList;
  final ValueNotifier<bool> visibilityNotifier;

  const BucketCard({
    super.key,
    required this.parameter,
    required this.historyList,
    required this.visibilityNotifier,
  });

  @override
  State<BucketCard> createState() => _BucketCardState();
}

class _BucketCardState extends State<BucketCard> {
  bool _isExpanded = false;
  ChartFilterState _chartFilter = const ChartFilterState(filter: ChartFilter.threeMonths);
  final NumberFormat _currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

  double _getBucketValueAt(History history) {
    final transaction = history.transactions[widget.parameter.id];
    return transaction?.actualValue ?? 0.0;
  }

  String _calculateAllocation(double currentBucketValue, double totalGlobal) {
    if (totalGlobal == 0) return '0.00';
    final percent = (currentBucketValue / totalGlobal) * 100;
    return percent.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.historyList.isEmpty) return const SizedBox();

    final l10n = AppLocalizations.of(context)!;

    final latestHistory = widget.historyList.last;
    final double currentBalance = _getBucketValueAt(latestHistory);
    final bool isUnderclock = currentBalance < widget.parameter.minValue;
    final Color healthColor = isUnderclock ? StackMoneyTheme.magentaNeon : StackMoneyTheme.cyanNeon;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibilityNotifier,
      builder: (context, isVisible, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: isVisible ? () => setState(() => _isExpanded = !_isExpanded) : null,
            child: StackMoneyCard(
              visibilityNotifier: widget.visibilityNotifier,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.parameter.where.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (isVisible)
                              Text(
                                l10n.allocation(_calculateAllocation(currentBalance, latestHistory.total)),
                                style: const TextStyle(
                                  color: StackMoneyTheme.mutedGrey,
                                  fontSize: 10,
                                  fontFamily: 'Orbitron',
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.min(_currencyFormat.format(widget.parameter.minValue)),
                          style: const TextStyle(color: StackMoneyTheme.mutedGrey, fontSize: 11),
                        ),
                      ],
                    ),
                    Text(
                      isVisible ? _currencyFormat.format(currentBalance) : l10n.hiddenValues,
                      style: TextStyle(
                        color: isVisible ? healthColor : StackMoneyTheme.mutedGrey,
                        fontSize: 16,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                // 💥 SEGURO: Renderização condicional limpa sem AnimatedSize que buga em Slivers
                if (_isExpanded && isVisible) ...[
                  const SizedBox(height: AppSizes.x8),
                  const Divider(color: Colors.white10, height: 1),
                  const SizedBox(height: AppSizes.x8),
                  _buildMiniChart(healthColor),
                  const SizedBox(height: AppSizes.x8),
                  TelemetryFilterBar(
                    currentState: _chartFilter,
                    isEnabled: true,
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
        );
      },
    );
  }

  Widget _buildMiniChart(Color activeColor) {
    List<FlSpot> spots = [];
    for (int i = 0; i < widget.historyList.length; i++) {
      spots.add(FlSpot(i.toDouble(), _getBucketValueAt(widget.historyList[i])));
    }

    return SizedBox(
      height: 100, // Altura fixa e segura para o fl_chart respirar
      child: LineChart(
        LineChartData(
          minY: widget.parameter.minValue * 0.5,
          maxY: widget.parameter.minValue * 1.5,
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: widget.parameter.minValue,
                color: Colors.white.withOpacity(0.15),
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
                  colors: [activeColor.withOpacity(0.06), Colors.transparent],
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