import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/widgets/title_text.dart';
import 'package:stack_money/features/history/widgets/history_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key = const ValueKey(route)});

  static const route = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleText(l10n.auditLogs),
        const SizedBox(height: AppSizes.sizedBoxMedium),
        ValueListenableBuilder(
          valueListenable: AppCoordinator.instance.history,
          builder: (_, fbHistory, _) {
            final history = fbHistory;
            history.sort((a, b) => b.date.compareTo(a.date));

            return Column(
              children: List.generate(history.length, (index) {
                final historyDay = history[index];
                final nextIndex = index + 1;
                final previousHistoryDay = nextIndex < history.length
                    ? history[nextIndex]
                    : null;

                return HistoryLog(
                  key: ValueKey(historyDay.id),
                  history: historyDay,
                  previousHistory: previousHistoryDay,
                );
              }),
            );
          },
        ),
      ],
    );
  }
}
