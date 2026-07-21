import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/features/configs/widgets/settings_switch_tile.dart';

class SystemPreferencesCard extends StatelessWidget {
  SystemPreferencesCard({super.key});

  final _boot = ValueNotifier(false);
  final _card = ValueNotifier(true);

  @override
  Widget build(BuildContext context) {
    return SmCard(
      title: 'System preferences',
      shadowColor: StackMoneyTheme.magentaNeon,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _boot,
            builder: (_, boot, _) {
              return SettingsSwitchTile(
                title: 'Iniciar no modo seguro',
                systemCode: 'SYS.SECURE_BOOT',
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
                title: 'Expandir Cards por Padrão',
                systemCode: 'DASH.CARDS_EXPAND',
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
