import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/transaction.dart';

class DayLog extends StatelessWidget {
  const DayLog({
    required this.securityMode,
    required this.transaction,
    super.key,
  });

  final Transaction transaction;
  final ValueListenable<bool> securityMode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return ValueListenableBuilder<bool>(
      valueListenable: securityMode,
      builder: (_, isVisible, _) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Esquerda: Ícone Tático + Informações (where e category)
              Row(
                children: [
                  _buildIcon(),
                  const SizedBox(width: AppSizes.x6),
                  _buildInfo(isVisible, textTheme, l10n),
                ],
              ),
              _buildValues(isVisible, textTheme, l10n),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: StackMoneyTheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: StackMoneyTheme.carbonGrey, width: 0.5),
      ),
      child: Icon(Icons.show_chart, size: 16, color: StackMoneyTheme.cyanNeon),
    );
  }

  Widget _buildInfo(
    bool isVisible,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          StackMoneyString.formatTitle(
            isVisible ? transaction.category : l10n.systemLocked,
          ),
          style: textTheme.titleSmall,
        ),
        Text(
          StackMoneyString.formatTitle(
            isVisible ? transaction.where : l10n.systemLocked,
          ),
          style: textTheme.bodySmall?.copyWith(
            color: StackMoneyTheme.mutedGrey,
          ),
        ),
      ],
    );
  }

  Widget _buildValues(
    bool isVisible,
    TextTheme textTheme,
    AppLocalizations l10n,
  ) {
    return Text(
      isVisible
          ? StackMoneyString.formatMoney(doubleValue: transaction.actualValue)
          : l10n.hiddenValues,
      style: textTheme.titleMedium?.copyWith(
        color: isVisible
            ? StackMoneyTheme.platinumSilver
            : StackMoneyTheme.mutedGrey,
      ),
    );
  }
}
