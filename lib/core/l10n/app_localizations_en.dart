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
  String get systemLocked => 'System Locked';

  @override
  String get telemetryStream => 'Telemetry Stream';

  @override
  String get hiddenValues => '••••••';

  @override
  String get liquidityBuffer => 'Liquidity Buffer';

  @override
  String get allocationBuckets => 'Allocation Buckets';

  @override
  String allocation(Object value) {
    return 'Alloc: $value%';
  }

  @override
  String min(Object value) {
    return 'Min: $value';
  }

  @override
  String get threeMonths => '3M';

  @override
  String get sixMonths => '6M';

  @override
  String get oneYear => '1Y';

  @override
  String get custom => 'Custom';

  @override
  String customLabel(Object end, Object start) {
    return '$start to $end';
  }

  @override
  String get noData => 'No Data';

  @override
  String get systemLinkFailed => 'System Link Failed';

  @override
  String get retryHandshake => 'Retry Handshake';
}
