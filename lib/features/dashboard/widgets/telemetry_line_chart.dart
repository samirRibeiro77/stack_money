import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/chart_filter.dart';
import 'package:stack_money/data/enum/currency_format.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/data/models/history.dart';

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

    if (filterState.filter == ChartFilter.custom && filterState.hasDates) {
      return rawHistoryData
          .where(
            (h) =>
                h.date.isAfter(filterState.start!) &&
                h.date.isBefore(filterState.end!),
          )
          .toList();
    }

    return rawHistoryData
        .where(
          (h) =>
              latestDate.difference(h.date).inDays <= filterState.filter.days,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final data = _filteredData;
    if (data.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            l10n.noData,
            style: textTheme.titleLarge?.copyWith(
              color: StackMoneyTheme.magentaNeon,
            ),
          ),
        ),
      );
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
              getTooltipColor: (spot) => StackMoneyTheme.surface.withValues(alpha: 0.95),
              tooltipBorder: const BorderSide(
                color: StackMoneyTheme.magentaNeon,
                width: 1.5,
              ),
              // Criamos o efeito chanfrado aplicando um padding assimétrico agressivo
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: AppSizes.x7,
                vertical: AppSizes.x4,
              ),
              tooltipRoundedRadius: AppSizes.navBarRadius,
              // Quase zero para cantos vivos e retos
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final historyItem = data[spot.x.toInt()];

                  return LineTooltipItem(
                    '${StackMoneyString.formatDate(historyItem.date, showYear: true)}\n${StackMoneyString.formatMoney(doubleValue: spot.y)}',
                    textTheme.labelMedium!.copyWith(
                      color: StackMoneyTheme.platinumSilver,
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
                        color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.8),
                        strokeWidth: 1.5,
                        dashArray: [
                          AppSizes.x2.toInt(),
                          AppSizes.x2.toInt(),
                        ], // Linha pontilhada tática
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotSquarePainter(
                              size: AppSizes.x4,
                              color: StackMoneyTheme.magentaNeon,
                              strokeColor: StackMoneyTheme.background,
                              strokeWidth: AppSizes.min,
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
                FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1),
            getDrawingVerticalLine: (value) =>
                FlLine(color: Colors.white.withValues(alpha: 0.04), strokeWidth: 1),
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
                  if (value == meta.min || value == meta.max) {
                    return const SizedBox();
                  }
                  return Text(
                    StackMoneyString.formatMoney(
                      doubleValue: value,
                      format: CurrencyFormat.compact
                    ),
                    style: textTheme.labelSmall,
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
                      child: Text(
                        StackMoneyString.formatDate(data[idx].date),
                        style: textTheme.bodySmall,
                      ),
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
                  : StackMoneyTheme.cyanNeon.withValues(alpha: 0.05),
              barWidth: AppSizes.min,
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
                    StackMoneyTheme.cyanNeon.withValues(
                      alpha: isSystemVisible ? 0.12 : 0.0,
                    ),
                    StackMoneyTheme.cyanNeon.withValues(alpha: 0.0),
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
