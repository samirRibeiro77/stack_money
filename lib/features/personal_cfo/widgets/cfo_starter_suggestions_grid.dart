import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/cfo_starter_suggestion.dart';

class CfoStarterSuggestionsGrid extends StatelessWidget {
  final ValueChanged<CfoStarterSuggestion> onSuggestionSelected;

  const CfoStarterSuggestionsGrid({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.containerTiny,
        vertical: AppSizes.sizedBoxLarge,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.aiSuggestions,
            textAlign: TextAlign.center,
            style: textTheme.labelMedium,
          ),
          SizedBox(height: AppSizes.sizedBoxMedium),
          Wrap(
            spacing: AppSizes.sizedBoxSmall,
            runSpacing: AppSizes.sizedBoxSmall,
            alignment: WrapAlignment.center,
            children: CfoStarterSuggestion.values.map((item) {
              return SmChipButton(
                item.title(l10n),
                icon: item.icon,
                onTap: () => onSuggestionSelected(item),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
