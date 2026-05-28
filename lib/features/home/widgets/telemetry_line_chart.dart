import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/domain/data/enum/chart_filter.dart';
import 'package:stack_money/domain/data/models/chart_filter_state.dart';
import 'package:stack_money/domain/data/models/history.dart';

class TelemetryLineChart extends StatelessWidget {
  final List<History> rawHistoryData;
  final ChartFilterState filterState;
  final bool isSystemVisible; // Se estiver em SYSTEM_LOCKED, apaga o gráfico

  const TelemetryLineChart({
    super.key,
    required this.rawHistoryData,
    required this.filterState,
    required this.isSystemVisible,
  });

  // Filtra os dados reais baseado no botão clicado
  List<History> get _filteredData {
    if (rawHistoryData.isEmpty) return [];
    final latestDate = rawHistoryData.last.date;

    switch (filterState.filter) {
      case ChartFilter.threeMonths:
        return rawHistoryData
            .where((h) => latestDate.difference(h.date).inDays <= filterState.filter.days)
            .toList();
      case ChartFilter.sixMonths:
        return rawHistoryData
            .where((h) => latestDate.difference(h.date).inDays <= filterState.filter.days)
            .toList();
      case ChartFilter.oneYear:
        return rawHistoryData
            .where((h) => latestDate.difference(h.date).inDays <= filterState.filter.days)
            .toList();
      case ChartFilter.custom:
        return rawHistoryData;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final data = _filteredData;
    if (data.isEmpty) {
      return SizedBox(height: 200, child: Center(child: Text(l10n.noData)));
    }

    // 📈 ESCALA DINÂMICA: Descobre o menor e maior valor para focar no zigue-zague real
    double minValue = data.map((e) => e.total).reduce((a, b) => a < b ? a : b);
    double maxValue = data.map((e) => e.total).reduce((a, b) => a > b ? a : b);

    // Dá um pequeno respiro nas bordas do gráfico (3% de margem)
    double padding = (maxValue - minValue) * 0.03;
    minValue -= padding;
    maxValue += padding;

    // Converte os nossos models para o formato aceito pela biblioteca fl_chart
    List<FlSpot> spots = [];
    for (int i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i].total));
    }

    final currencyFormat = NumberFormat.compactSimpleCurrency(locale: 'pt_BR');

    return Container(
      height: 220,
      padding: const EdgeInsets.only(right: AppSizes.x8, top: AppSizes.x6),
      child: LineChart(
        duration: const Duration(milliseconds: 450),
        // Animação fluida de transição de ondas
        curve: Curves.easeInOutCubic,
        LineChartData(
          minY: minValue,
          maxY: maxValue,
          minX: 0,
          maxX: (spots.length - 1).toDouble(),

          // 🕹️ COMPORTAMENTO DE TOQUE (MIRA MAGENTA + TOOLTIP CHANFRADO)
          lineTouchData: LineTouchData(
            enabled: isSystemVisible, // Desativa toque se estiver encriptado
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => StackMoneyTheme.surface,
              tooltipBorder: const BorderSide(
                color: StackMoneyTheme.magentaNeon,
                width: 1.5,
              ),
              // Criamos o efeito chanfrado aplicando um padding assimétrico agressivo
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.x7,
                vertical: AppSizes.x4,
              ),
              tooltipRoundedRadius: 2,
              // Quase zero para cantos vivos e retos
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final historyItem = data[spot.x.toInt()];
                  final dateStr = DateFormat(
                    'dd/MM/yy',
                  ).format(historyItem.date);
                  final valStr = NumberFormat.currency(
                    locale: 'pt_BR',
                    symbol: 'R\$',
                  ).format(spot.y);

                  return LineTooltipItem(
                    '$dateStr\n$valStr',
                    const TextStyle(
                      color: Color(0xFFE2E8F0), // Branco Metálico
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            // 🎯 MIRA TELESCÓPICA VERTICAL
            getTouchedSpotIndicator:
                (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: StackMoneyTheme.magentaNeon.withOpacity(0.8),
                        strokeWidth: 1.5,
                        dashArray: [4, 4], // Linha pontilhada tática
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotSquarePainter(
                              size: 8,
                              color: StackMoneyTheme.magentaNeon,
                              strokeColor: StackMoneyTheme.background,
                              strokeWidth: 2,
                            ),
                      ),
                    );
                  }).toList();
                },
          ),

          // 🌌 GRADE HOLOGRÁFICA DE FUNDO (PROTEGIDA CONTRA DIVISÃO POR ZERO)
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            // 💥 CORREÇÃO AQUI: Se a variação for zero, assume 1.0 para não estourar a assertion
            horizontalInterval: (maxValue - minValue) == 0
                ? 1.0
                : (maxValue - minValue) / 4,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: Colors.white.withOpacity(0.04), strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.white.withOpacity(0.04), strokeWidth: 1),
          ),

          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            // Legendas Laterais (Valores reduzidos compactos)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: isSystemVisible,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  if (value == meta.min || value == meta.max)
                    return const SizedBox();
                  return Text(
                    currencyFormat.format(value),
                    style: const TextStyle(
                      color: StackMoneyTheme.mutedGrey,
                      fontSize: 10,
                      fontFamily: 'Orbitron',
                    ),
                  );
                },
              ),
            ),
            // Legendas Inferiores (Datas formatadas curtas)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: isSystemVisible,
                reservedSize: 22,
                interval: (spots.length / 4).clamp(1, double.infinity),
                getTitlesWidget: (value, meta) {
                  int idx = value.toInt();
                  if (idx >= 0 && idx < data.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: AppSizes.x3),
                      child: Text(DateFormat('dd/MM').format(data[idx].date)),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),

          // 🚀 VETOR DE RENDIMENTO EM CIANO NEON + GRADIENTE DE NÉVOA
          lineBarsData: [
            LineChartBarData(
              spots: isSystemVisible
                  ? spots
                  : spots.map((s) => FlSpot(s.x, minValue)).toList(),
              // Achata o gráfico se oculto
              isCurved: true,
              preventCurveOverShooting: true,
              color: isSystemVisible
                  ? StackMoneyTheme.cyanNeon
                  : StackMoneyTheme.cyanNeon.withOpacity(0.05),
              barWidth: 2,
              // Mini-quadrados nos pontos de auditoria
              dotData: FlDotData(
                show: isSystemVisible,
                getDotPainter: (spot, percent, barData, index) =>
                    FlDotSquarePainter(
                      size: 5,
                      color: StackMoneyTheme.cyanNeon,
                      strokeColor: StackMoneyTheme.background,
                      strokeWidth: 1.5,
                    ),
              ),
              // Névoa inferior
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    StackMoneyTheme.cyanNeon.withOpacity(
                      isSystemVisible ? 0.12 : 0.0,
                    ),
                    StackMoneyTheme.cyanNeon.withOpacity(0.0),
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
