import 'package:flutter/material.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/security_type.dart';

class SecurityText extends StatelessWidget {
  const SecurityText(
    this.text, {
    super.key,
    this.style,
    this.type = SecurityType.mask,
    this.activeColor = StackMoneyTheme.platinumSilver,
    this.mutedColor = StackMoneyTheme.mutedGrey,
  });

  final String text;
  final TextStyle? style;
  final SecurityType type;
  final Color? activeColor;
  final Color? mutedColor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return Text(
      isSecureActive ? _getMask(l10n) : text,
      style: style?.copyWith(color: isSecureActive ? mutedColor : activeColor),
    );
  }

  String _getMask(AppLocalizations l10n) {
    switch (type) {
      case SecurityType.systemLocked:
        return StackMoneyString.formatTitle(l10n.systemLocked);
      case SecurityType.mask:
        return l10n.hiddenValues;
    }
  }
}
