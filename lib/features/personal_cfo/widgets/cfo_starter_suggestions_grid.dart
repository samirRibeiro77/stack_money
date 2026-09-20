import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/sm_chip_button.dart';
import 'package:stack_money/data/enum/cfo_starter_suggestion.dart';

class CfoStarterSuggestionsGrid extends StatelessWidget {
  final ValueChanged<String> onSuggestionSelected;

  const CfoStarterSuggestionsGrid({
    super.key,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final suggestions = CfoStarterSuggestion.values;

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
          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSizes.sizedBoxSmall,
              mainAxisSpacing: AppSizes.sizedBoxSmall,
              childAspectRatio: 5,
            ),
            itemCount: suggestions.length,
            itemBuilder: (_, index) {
              final item = suggestions[index];

              return SmChipButton(
                item.title(l10n),
                icon: item.icon,
                center: true,
                onTap: () => onSuggestionSelected(item.prompt(l10n)),
              );
            },
          ),
        ],
      ),
    );
  }
}
