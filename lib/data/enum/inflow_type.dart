import 'package:stack_money/core/l10n/app_localizations.dart';

enum InflowType {
  fixed,
  percentageBase;

  String toJson() => name;
  static InflowType fromJson(String json) => InflowType.values.firstWhere((e) => e.name == json, orElse: () => InflowType.fixed);

  String symbol(AppLocalizations l10n) {
    switch (this) {
      case fixed: return l10n.brlCurrency;
      case percentageBase: return l10n.percentSignal;
    }
  }
}