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
  ChartFilterState _chartFilter = const ChartFilterState(
    filter: ChartFilter.threeMonths,
  );
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
  );

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
    final Color healthColor = isUnderclock
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    return ValueListenableBuilder<bool>(
      valueListenable: widget.visibilityNotifier,
      builder: (context, isVisible, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GestureDetector(
            onTap: isVisible
                ? () => setState(() => _isExpanded = !_isExpanded)
                : null,
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
                              widget.parameter.id.toUpperCase(),
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
                                l10n.allocation(
                                  _calculateAllocation(
                                    currentBalance,
                                    latestHistory.total,
                                  ),
                                ),
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
                          l10n.min(
                            _currencyFormat.format(widget.parameter.minValue),
                          ),
                          style: const TextStyle(
                            color: StackMoneyTheme.mutedGrey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      isVisible
                          ? _currencyFormat.format(currentBalance)
                          : l10n.hiddenValues,
                      style: TextStyle(
                        color: isVisible
                            ? healthColor
                            : StackMoneyTheme.mutedGrey,
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
    if (widget.historyList.isEmpty) return const SizedBox.shrink();

    // 🎯 1. CORREÇÃO DA FIÇÃO: Filtra o histórico com base no botão clicado (_chartFilter)
    final latestDate = widget.historyList.last.date;

    List<History> filteredHistory = widget.historyList.where((h) {
      if (_chartFilter.filter == ChartFilter.custom && _chartFilter.hasDates) {
        return h.date.isAfter(_chartFilter.start!) && h.date.isBefore(_chartFilter.end!);
      }

      return latestDate.difference(h.date).inDays <= _chartFilter.filter.days;
    }).toList();

    // Fallback de segurança se o filtro retornar vazio (garante que o app não quebre)
    if (filteredHistory.isEmpty) filteredHistory = [widget.historyList.last];

    // 📈 2. Recalcula os saldos e a Escala Dinâmica usando APENAS o período filtrado!
    List<double> values = filteredHistory
        .map((h) => _getBucketValueAt(h))
        .toList();
    values.add(
      widget.parameter.minValue,
    ); // Mantém a linha de meta dentro da régua

    double absoluteMin = values.reduce((a, b) => a < b ? a : b);
    double absoluteMax = values.reduce((a, b) => a > b ? a : b);

    double delta = absoluteMax - absoluteMin;
    if (delta == 0) delta = widget.parameter.minValue.abs() * 0.2;
    if (delta == 0) delta = 100.0;

    double computedMinY = absoluteMin - (delta * 0.1);
    double computedMaxY = absoluteMax + (delta * 0.1);

    // ⚡️ 3. Converte os pontos filtrados e cronológicos para o fl_chart
    List<FlSpot> spots = [];
    for (int i = 0; i < filteredHistory.length; i++) {
      spots.add(FlSpot(i.toDouble(), _getBucketValueAt(filteredHistory[i])));
    }

    return SizedBox(
      height: 110,
      child: LineChart(
        duration: const Duration(milliseconds: 350),
        // Adiciona a transição fluida de onda!
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
                  final prefix = deltaValue >= 0 ? '+' : '';
                  return LineTooltipItem(
                    '$prefix${_currencyFormat.format(deltaValue)}',
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
