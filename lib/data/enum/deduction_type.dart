import 'package:stack_money/core/l10n/app_localizations.dart';

enum DeductionType {
  fixed,
  percentageGross;

  String toJson() => name;
  static DeductionType fromJson(String json) => DeductionType.values.firstWhere((e) => e.name == json, orElse: () => DeductionType.fixed);

  String symbol(AppLocalizations l10n) {
    switch (this) {
      case fixed: return l10n.brlCurrency;
      case percentageGross: return l10n.percentSignal;
    }
  }
}