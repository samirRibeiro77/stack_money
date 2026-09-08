import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/core/widgets/title_text.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_filter_bar.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_line_chart.dart';

class TelemetryCard extends StatelessWidget {
  final List<History> history;
  final ChartFilterState currentFilter;
  final ValueChanged<ChartFilterState> updateChartFilter;

  const TelemetryCard({
    required this.history,
    required this.currentFilter,
    required this.updateChartFilter,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SmCard(
      removePadding: true,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: AppSizes.x10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: AppSizes.x8),
              child: TitleText(l10n.telemetryStream),
            ),
            SizedBox(
              height: AppSizes.containerMedium,
              child: TelemetryLineChart(
                rawHistoryData: history,
                filterState: currentFilter,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSizes.x8),
              child: Column(
                children: [
                  const SizedBox(height: AppSizes.sizedBoxMedium),
                  const Divider(height: 1),
                  const SizedBox(height: AppSizes.sizedBoxMedium),
                  TelemetryFilterBar(
                    currentState: currentFilter,
                    firstDate: history.firstOrNull?.date.toDate(),
                    onFilterChanged: updateChartFilter,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
