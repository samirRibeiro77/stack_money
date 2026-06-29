import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/title_text.dart';
import 'package:stack_money/features/history/manager/history_manager.dart';
import 'package:stack_money/features/history/widgets/history_log.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key = const ValueKey(route)});

  static const route = '/history';

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _manager = HistoryManager();

  @override
  void initState() {
    super.initState();
    _manager.loadFirebaseHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder(
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

        return ValueListenableBuilder(
          valueListenable: _manager.hasError,
          builder: (_, hasError, _) {
            if (hasError || _manager.logs.isEmpty) {
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
                        onPressed: _manager.loadFirebaseHistoryData,
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

            return _buildHistoryContent(l10n, textTheme);
          },
        );
      },
    );
  }

  Widget _buildHistoryContent(AppLocalizations l10n, TextTheme textTheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleText(l10n.auditLogs),
        const SizedBox(height: AppSizes.sizedBoxMedium),

        ...List.generate(_manager.logs.length, (index) {
          final historyDay = _manager.logs[index];
          final nextIndex = index + 1;
          final previousHistoryDay = nextIndex < _manager.logs.length
              ? _manager.logs[nextIndex]
              : null;

          return HistoryLog(
            history: historyDay,
            previousHistory: previousHistoryDay,
          );
        }),
      ],
    );
  }
}
