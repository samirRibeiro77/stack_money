import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';

class SettingsSwitchTile extends StatelessWidget {
  final String title;
  final String systemCode;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    required this.title,
    required this.systemCode,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    final statusText = value ? l10n.enabled : l10n.disabled;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: AppTypography.weightMedium,
                  ),
                ),
                const SizedBox(height: AppSizes.min),
                Text(
                  '${StackMoneyString.formatTitle(systemCode)}: ${StackMoneyString.formatTitle(statusText)}',
                  style: textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: StackMoneyTheme.magentaNeon,
            activeThumbColor: StackMoneyTheme.surface,
            inactiveTrackColor: StackMoneyTheme.surface,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
