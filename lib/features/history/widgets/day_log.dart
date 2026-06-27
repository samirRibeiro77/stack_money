import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/models/transaction.dart';

class DayLog extends StatelessWidget {
  DayLog({
    required this.transaction,
    Transaction? previousTransaction,
    super.key,
  }) : delta = _calculateDelta(transaction, previousTransaction);

  final Transaction transaction;
  late final double delta;

  static double _calculateDelta(Transaction t, Transaction? ot) {
    if (ot == null) return 0;
    final double prevVal = ot.actualValue;
    if (prevVal <= 0) return 0;
    return ((t.actualValue - prevVal) / prevVal) * 100;
  }

  Color get color {
    switch (delta) {
      case > 0:
        return StackMoneyTheme.cyanNeon;
      case < 0:
        return StackMoneyTheme.magentaNeon;
      default:
        return StackMoneyTheme.mutedGrey;
    }
  }

  IconData get icon {
    switch (delta) {
      case > 0:
        return Icons.trending_up_rounded;
      case < 0:
        return Icons.trending_down_rounded;
      default:
        return Icons.trending_flat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIcon(),
          const SizedBox(width: AppSizes.sizedBoxMedium),
          _buildInfo(textTheme),
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
      child: Icon(icon, size: AppSizes.x8, color: color),
    );
  }

  Widget _buildInfo(TextTheme textTheme) {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SecurityText(
          StackMoneyString.formatMoney(transaction.actualValue, symbol: true),
          style: textTheme.bodyMedium,
        ),
        SecurityText(
          StackMoneyString.formatPercentage(
            delta,
            decimal: 2,
            operator: true,
            symbol: true,
          ),
          style: textTheme.labelSmall?.copyWith(
            fontSize: AppTypography.fontSmallest,
            fontWeight: AppTypography.weightBold,
          ),
          activeColor: color.withValues(alpha: 0.6),
        ),
      ],
    );
  }
}
