import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/features/history/widgets/day_log.dart';

class HistoryLog extends StatelessWidget {
  const HistoryLog({required this.history, this.previousHistory, super.key});

  final History history;
  final History? previousHistory;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (history.transactions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSizes.sizedBoxMedium),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              StackMoneyString.formatDate(
                history.date,
                showYear: true,
                hideSameYear: false,
                fullYear: true,
              ),
              style: textTheme.bodyMedium?.copyWith(
                color: StackMoneyTheme.mutedGrey,
              ),
            ),
            SecurityText(
              StackMoneyString.formatMoney(history.total, symbol: true),
              activeColor: StackMoneyTheme.mutedGrey,
              style: textTheme.bodyMedium,
            ),
          ],
        ),
        const Divider(),
        ...history.transactions.values.map((tx) {
          final prevTx = previousHistory?.transactions.values
              .where((pt) => pt.id == tx.id)
              .firstOrNull;

          return DayLog(transaction: tx, previousTransaction: prevTx);
        }),
        const SizedBox(height: AppSizes.sizedBoxLarge),
      ],
    );
  }
}
