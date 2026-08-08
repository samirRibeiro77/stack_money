import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/user_settings_scope.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/features/settings/widgets/settings_switch_tile.dart';

class SystemPreferencesCard extends StatelessWidget {
  const SystemPreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final manager = UserSettingsScope.of(context);

    return SmCard(
      title: l10n.systemPreferences,
      shadowColor: StackMoneyTheme.magentaNeon,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: manager.securityMode,
            builder: (_, boot, _) {
              return SettingsSwitchTile(
                title: l10n.securityModeTitle,
                systemCode: l10n.securityModeCode,
                value: boot,
                onChanged: manager.toggleSecurityMode,
              );
            },
          ),
          ValueListenableBuilder(
            valueListenable: manager.cardExpand,
            builder: (_, card, _) {
              return SettingsSwitchTile(
                title: l10n.cardExpandTitle,
                systemCode: l10n.cardExpandCode,
                value: card,
                onChanged: manager.toggleCardExpand,
              );
            },
          ),
        ],
      ),
    );
  }
}
