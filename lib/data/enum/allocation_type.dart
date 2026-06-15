import 'package:stack_money/core/l10n/app_localizations.dart';

enum AllocationType {
  fixed,
  percentageNet,
  percentageGross;

  String toJson() => name;

  static AllocationType fromJson(String json) {
    return AllocationType.values.firstWhere(
          (e) => e.name == json,
      orElse: () => AllocationType.fixed,
    );
  }

  String symbol(AppLocalizations l10n) {
    switch (this) {
      case fixed: return l10n.brlCurrency;
      case percentageNet: return l10n.percentNet;
      case percentageGross: return l10n.percentGross;
    }
  }
}