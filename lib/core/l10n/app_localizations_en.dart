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
  String get allocation => 'Allocation: ';

  @override
  String get min => 'Min: ';

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

  @override
  String get auditLogs => 'Audit Logs';

  @override
  String get securityBiometricReason =>
      'Authenticate to view your sensitive data and balances.';

  @override
  String get cancel => 'Cancel';

  @override
  String get bucketsConfig => 'Buckets Config';

  @override
  String get newBucket => 'Add new bucket';

  @override
  String get category => 'Category';

  @override
  String get where => 'Where';

  @override
  String get minValue => 'Min Value';

  @override
  String get liquidity => 'Liquidity';

  @override
  String get percentSignal => '%';

  @override
  String get plansConfig => 'Plans Config';

  @override
  String get newPlan => 'Add new plan';

  @override
  String get activePlan => 'Active plan';

  @override
  String get setActive => 'Set active';

  @override
  String get grossRevenue => 'Gross Revenue';

  @override
  String get remainingRest => 'Remaining Rest';

  @override
  String get baseSalary => 'Base salary';

  @override
  String get type => 'Type';

  @override
  String get brlCurrency => 'R\$';

  @override
  String get day => 'Day';

  @override
  String converted(Object value) {
    return 'Converted: $value';
  }

  @override
  String get notAvailable => 'N/A';

  @override
  String get mandatoryDeductions => 'Mandatory deductions';

  @override
  String get deductionName => 'Deduction name';

  @override
  String get target => 'Target';

  @override
  String get rule => 'Rule';

  @override
  String deducted(Object value) {
    return 'Deducted: $value';
  }

  @override
  String get totalNet => 'Total net';

  @override
  String get totalRest => 'Total rest:';

  @override
  String netDay(Object value) {
    return 'Day $value';
  }

  @override
  String netValue(Object value) {
    return 'Net: $value';
  }

  @override
  String rest(Object value) {
    return 'Rest: $value';
  }

  @override
  String get systemOverflow => '[ SYSTEM_OVERFLOW ]';

  @override
  String overflowBy(Object value) {
    return 'Over ($value)';
  }
}
