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
  String get retry => 'Retry';

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
  String get newBucket => 'New bucket';

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
  String get newPlan => 'New plan';

  @override
  String get activePlan => 'Active plan';

  @override
  String get active => 'Active';

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

  @override
  String get newDistributionRule => 'New distribution';

  @override
  String get subcategory => 'Subcategory';

  @override
  String get percentNet => '% net';

  @override
  String get percentGross => '% gross';

  @override
  String get copy => 'Copy';

  @override
  String get share => 'Share';

  @override
  String get archive => 'Archive';

  @override
  String get delete => 'Delete';

  @override
  String dayX(Object d) {
    return 'D$d';
  }

  @override
  String get lastKnownValue => 'Last known:';

  @override
  String get moneySprint => 'Money Sprint';

  @override
  String get liquid => 'Liquid';

  @override
  String get invest => 'Invest';

  @override
  String get addToMin => 'Add to min:';

  @override
  String get subToMin => 'Sub from min:';

  @override
  String get positiveActualValue => 'Positive actual value';

  @override
  String get negativeActualValue => 'Negative actual value';

  @override
  String get exit => 'Exit';

  @override
  String get previous => 'Previous';

  @override
  String get next => 'Next';

  @override
  String get finish => 'Finish';

  @override
  String get systemWarning => 'System Warning';

  @override
  String get confirm => 'Confirm';

  @override
  String get deny => 'Deny';

  @override
  String get deletePlanMessage => 'Execute purge protocol on Salary Plan?';

  @override
  String get deletePlanNote => 'All forecast alignments will be expurged.';

  @override
  String get deleteBucketMessage => 'Execute purge protocol on bucket?';

  @override
  String get deleteBucketNote => 'All allocation parameters will be expurged.';

  @override
  String get deleteInflowMessage => 'Execute purge protocol on inflow?';

  @override
  String get deleteInflowNote => 'All inflow details will be expurged.';

  @override
  String get deletedInflow => 'Gross revenue removed';

  @override
  String get deleteOutflowMessage => 'Execute purge protocol on outflow?';

  @override
  String get deleteOutflowNote => 'All outflow details will be expurged.';

  @override
  String get deletedOutflow => 'Mandatory deduction removed';

  @override
  String get deleteDistributionMessage =>
      'Execute purge protocol on distribution?';

  @override
  String get deleteDistributionNote =>
      'All distribution details will be expurged.';

  @override
  String get deletedDistribution => 'Distribution rule removed';

  @override
  String get undo => 'Undo';

  @override
  String get selectRange => 'Select range';

  @override
  String get startDate => 'Start date';

  @override
  String get endDate => 'End date';

  @override
  String get confirmContributionSprintTitle => 'Confirm Sprint';

  @override
  String confirmContributionSprintMessage(Object liquidity, Object netWorth) {
    return '[ METRICS_SNAPSHOT ]\nNet Worth: $netWorth\nLiquidity: $liquidity';
  }

  @override
  String confirmContributionSprintNote(Object changes) {
    return '[ CHANGELOG ]\n$changes';
  }

  @override
  String confirmContributionSprintNoteLine(
    Object bucket,
    Object newValue,
    Object oldValue,
  ) {
    return '$bucket: $oldValue -> $newValue';
  }

  @override
  String get noChangesDetected => 'No changes detected';

  @override
  String get arrowUp => '▲';

  @override
  String get arrowDown => '▼';

  @override
  String get reorderBuckets => 'Reorder buckets';

  @override
  String get filterByPosition => 'Bucket position';

  @override
  String get filterByName => 'Bucket name';

  @override
  String get filterByActual => 'Higher actual value';

  @override
  String get filterByMin => 'Lower min value';

  @override
  String get filterByAlloc => 'Wallet allocation';

  @override
  String get failDeleteBucketWithValue =>
      'Bucket has \'MIN_VALUE\' filled, can\'t be deleted';

  @override
  String get planMoneySprintDay => 'Planned day to update your money';

  @override
  String get start => 'Start';

  @override
  String get settings => 'Settings';

  @override
  String get adminName => 'ADMIN_NAME';

  @override
  String get adminEmail => 'ADMIN_EMAIL';

  @override
  String get logout => 'Logout';

  @override
  String get systemPreferences => 'System Preferences';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get securityModeTitle => 'Boot under security mode';

  @override
  String get securityModeCode => 'SYS.SECURE_MODE';

  @override
  String get cardExpandTitle => 'Open with cards expanded';

  @override
  String get cardExpandCode => 'DASH.CARDS_EXPAND';

  @override
  String get defaultFilterCode => 'DASH.DEFAULT_FILTER';

  @override
  String get exportData => 'Export data';

  @override
  String exportDataPlans(Object qty) {
    return 'Plans: $qty';
  }

  @override
  String exportDataHistory(Object qty) {
    return 'History: $qty';
  }

  @override
  String exportDataBuckets(Object qty) {
    return 'Buckets: $qty';
  }

  @override
  String exportDataJsonSize(Object size) {
    return 'JSON size: $size';
  }

  @override
  String get exportJsonData => 'Export JSON data';

  @override
  String get rememberLast => 'Remember last';

  @override
  String get settingsChangedTitle => 'Settings changes';

  @override
  String settingsChangedMessage(Object qty) {
    return 'Identified $qty changes on your preferences:';
  }

  @override
  String settingsChangedNote(Object code, Object current, Object old) {
    return '• $code:\n   $old ➔ $current\n';
  }

  @override
  String get failedToSignIn => 'Failed to sign-in';

  @override
  String get failedToSaveUser => 'Failed to save user changes';

  @override
  String get systemCode => 'Core.Sys';

  @override
  String get initializing => 'Loading...';

  @override
  String get loadingUser =>
      'AUTH: Infiltrating networks and decrypting user profile...';

  @override
  String get loadingPlan =>
      'ALLOCATION: Syncing salary distribution matrices...';

  @override
  String get loadingBucket =>
      'VAULTS: Securing funds and digital sub-vaults...';

  @override
  String get loadingChats =>
      'AI: Syncing secure channels and AI financial insights...';

  @override
  String get loadingHistory =>
      'TRAILS: Reconstituting transaction logs and ledger history...';

  @override
  String get error => 'Error';

  @override
  String get reload => 'Reload App';

  @override
  String get payload => 'Payload';

  @override
  String get stackTrace => 'Stack Trace';

  @override
  String get exception => 'Exception';

  @override
  String get dataMightBeLost => 'Some data may have been lost or corrupted...';

  @override
  String get failedSave => 'Failed to save data...';

  @override
  String get failedUpdateLastFilter => 'Failed updating last filter...';

  @override
  String get failedInitializingNewSlot => 'Failed to initialize a new slot...';

  @override
  String get failedArchivePlan => 'Failed to archive plan...';

  @override
  String get failedPurgePlan => 'Failed to purge plan...';

  @override
  String get planChangedTitle => 'Plan changes';

  @override
  String planChangedMessage(Object qty) {
    return 'Identified $qty changes on plan:';
  }

  @override
  String planChangedName(Object current, Object old) {
    return '• Name:\n   $old ➔ $current\n';
  }

  @override
  String planChangedBaseSalary(Object current, Object old) {
    return '• Base Salary:\n   $old ➔ $current\n';
  }

  @override
  String planChangedItem(Object code, Object current, Object old) {
    return '• $code:\n   $old items ➔ $current items\n';
  }

  @override
  String get planChangedIncoming => 'Incoming';

  @override
  String get planChangedOutcoming => 'Deduction';

  @override
  String get planChangedDistribution => 'Distribution';

  @override
  String get planChangedNoChanges => 'No changes detected...';

  @override
  String get planChangedValueDetails => 'Some details has changed';

  @override
  String get hud => 'HUD';

  @override
  String get plans => 'Plans';

  @override
  String get ai => 'AI';

  @override
  String get buckets => 'Buckets';

  @override
  String get log => 'Log';

  @override
  String get newChat => 'New Chat';

  @override
  String get askCfo => 'Ask your CFO...';

  @override
  String get reject => 'Reject';

  @override
  String get apply => 'Apply';

  @override
  String get pending => '↺ Pending';

  @override
  String get approved => '✓ Approved';

  @override
  String get rejected => '✕ Rejected';

  @override
  String get personalCfo => 'Personal CFO • Lab';

  @override
  String get chatConnectionError =>
      '⚡ *Fail to connect to the CFO terminal...\n_Try again later!_*';

  @override
  String get chatEmpty =>
      'Personal AI CFO connected sucessfully!\nAsk something right away...';

  @override
  String get timeAgoJustNow => 'Just now';

  @override
  String timeAgoMin(Object m) {
    return '${m}m';
  }

  @override
  String timeAgoHour(Object h) {
    return '${h}h';
  }

  @override
  String get timeAgoYesterday => 'Yesterday';

  @override
  String timeAgoDay(Object d) {
    return '${d}d';
  }

  @override
  String timeAgoWhen(Object d, Object m, Object y) {
    return '$y/$m/$d';
  }

  @override
  String get failedPurgeChatThread => 'Failed to purge chat thread...';
}
