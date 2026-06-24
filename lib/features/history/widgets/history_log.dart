import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/features/history/widgets/day_log.dart';

class HistoryLog extends StatelessWidget {
  const HistoryLog({
    required this.securityMode,
    required this.history,
    super.key,
  });

  final History history;
  final ValueListenable<bool> securityMode;

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
              style: textTheme.bodyMedium?.copyWith(color: StackMoneyTheme.mutedGrey),
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
          return DayLog(transaction: tx);
        }),
        const SizedBox(height: AppSizes.sizedBoxLarge),
      ],
    );
  }
}
