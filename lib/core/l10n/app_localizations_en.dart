// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Stack Money';

  @override
  String get appNameTwoLines => 'Stack\nMoney';

  @override
  String get loginWithGoogle => 'Sign in with Google';

  @override
  String get unknow => 'Unknow';

  @override
  String get netWorth => 'Net Worth';

  @override
  String get systemLocked => 'SYSTEM_LOCKED';

  @override
  String get hiddenValues => '••••••';

  @override
  String get liquidityBuffer => 'Liquidity Buffer';
}
