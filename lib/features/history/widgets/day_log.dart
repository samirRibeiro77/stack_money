import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/models/transaction.dart';

class DayLog extends StatelessWidget {
  const DayLog({required this.transaction, super.key});

  final Transaction transaction;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIcon(),
          const SizedBox(width: AppSizes.x6),
          _buildInfo(textTheme, l10n),
          const Expanded(child: SizedBox()),
          _buildValues(textTheme),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.x4),
      decoration: BoxDecoration(
        color: StackMoneyTheme.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
        border: Border.all(color: StackMoneyTheme.carbonGrey, width: 0.5),
      ),
      child: Icon(Icons.show_chart, size: AppSizes.x8, color: StackMoneyTheme.cyanNeon),
    );
  }

  Widget _buildInfo(TextTheme textTheme, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SecurityText(
          StackMoneyString.formatTitle(transaction.category),
          type: SecurityType.systemLocked,
          style: textTheme.titleSmall,
        ),
        SecurityText(
          StackMoneyString.formatTitle(transaction.where),
          style: textTheme.bodySmall,
          activeColor: StackMoneyTheme.mutedGrey,
        ),
      ],
    );
  }

  Widget _buildValues(TextTheme textTheme) {
    return SecurityText(
      StackMoneyString.formatMoney(transaction.actualValue, symbol: true),
      type: SecurityType.mask,
      style: textTheme.bodyLarge,
    );
  }
}
