import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';

class BucketsTitle extends StatelessWidget {
  const BucketsTitle({
    required this.toggleBuckets,
    required this.expandState,
    super.key,
  });

  final VoidCallback toggleBuckets;
  final ValueListenable<bool> expandState;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          StackMoneyString.formatTitle(l10n.bucketsConfig),
          style: textTheme.labelLarge?.copyWith(
            fontWeight: AppTypography.weightBold,
            letterSpacing: 1.5,
            color: StackMoneyTheme.mutedGrey,
          ),
        ),
        if (!isSecureActive)
          IconButton(
            onPressed: toggleBuckets,
            icon: ValueListenableBuilder<bool>(
              valueListenable: expandState,
              builder: (_, isExpanded, _) {
                return Icon(
                  isExpanded ? Icons.unfold_more : Icons.unfold_less,
                  color: isExpanded
                      ? StackMoneyTheme.cyanNeon
                      : StackMoneyTheme.magentaNeon,
                  size: AppSizes.x10,
                );
              },
            ),
          ),
      ],
    );
  }
}
