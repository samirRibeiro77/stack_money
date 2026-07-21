import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/features/configs/widgets/settings_switch_tile.dart';

class SystemPreferencesCard extends StatelessWidget {
  SystemPreferencesCard({super.key});

  final _boot = ValueNotifier(false);
  final _card = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SmCard(
      title: l10n.systemPreferences,
      shadowColor: StackMoneyTheme.magentaNeon,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _boot,
            builder: (_, boot, _) {
              return SettingsSwitchTile(
                title: l10n.securityModeTitle,
                systemCode: l10n.securityModeCode,
                value: boot,
                onChanged: (val) {
                  _boot.value = val;
                },
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: _card,
            builder: (_, card, _) {
              return SettingsSwitchTile(
                title: l10n.cardExpandTitle,
                systemCode: l10n.cardExpandCode,
                value: card,
                onChanged: (val) {
                  _card.value = val;
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
