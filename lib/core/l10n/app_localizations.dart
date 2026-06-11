import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt'),
  ];

  /// The official name of the application
  ///
  /// In en, this message translates to:
  /// **'Stack Money'**
  String get appName;

  /// The official name of the application but using two lines
  ///
  /// In en, this message translates to:
  /// **'Stack\nMoney'**
  String get appNameTwoLines;

  /// Text displayed on the primary authentication button
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginWithGoogle;

  /// Unknow value
  ///
  /// In en, this message translates to:
  /// **'Unknow'**
  String get unknow;

  /// Net Worth for all money
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorth;

  /// Values hidden for the user
  ///
  /// In en, this message translates to:
  /// **'System Locked'**
  String get systemLocked;

  /// Chart telemetry stream title
  ///
  /// In en, this message translates to:
  /// **'Telemetry Stream'**
  String get telemetryStream;

  /// Use when values are hidden
  ///
  /// In en, this message translates to:
  /// **'••••••'**
  String get hiddenValues;

  /// Immediate liquidity total
  ///
  /// In en, this message translates to:
  /// **'Liquidity Buffer'**
  String get liquidityBuffer;

  /// Allocation buckets title
  ///
  /// In en, this message translates to:
  /// **'Allocation Buckets'**
  String get allocationBuckets;

  /// Allocation on wallet
  ///
  /// In en, this message translates to:
  /// **'Alloc: {value}%'**
  String allocation(Object value);

  /// Min value for bucket
  ///
  /// In en, this message translates to:
  /// **'Min: {value}'**
  String min(Object value);

  /// 3 months filter
  ///
  /// In en, this message translates to:
  /// **'3M'**
  String get threeMonths;

  /// 6 months filter
  ///
  /// In en, this message translates to:
  /// **'6M'**
  String get sixMonths;

  /// 1 year filter
  ///
  /// In en, this message translates to:
  /// **'1Y'**
  String get oneYear;

  /// Custom filter
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// Custom filter with date
  ///
  /// In en, this message translates to:
  /// **'{start} to {end}'**
  String customLabel(Object end, Object start);

  /// No data found
  ///
  /// In en, this message translates to:
  /// **'No Data'**
  String get noData;

  /// Error title when data is not found
  ///
  /// In en, this message translates to:
  /// **'System Link Failed'**
  String get systemLinkFailed;

  /// Retry message for data management
  ///
  /// In en, this message translates to:
  /// **'Retry Handshake'**
  String get retryHandshake;

  /// Audit ledger logs title
  ///
  /// In en, this message translates to:
  /// **'Audit Logs'**
  String get auditLogs;

  /// Reason to use local authentication to see sensitive data
  ///
  /// In en, this message translates to:
  /// **'Authenticate to view your sensitive data and balances.'**
  String get securityBiometricReason;

  /// Cancel message
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Buckets Config title
  ///
  /// In en, this message translates to:
  /// **'Buckets Config'**
  String get bucketsConfig;

  /// Add new bucket slot text
  ///
  /// In en, this message translates to:
  /// **'Add new bucket'**
  String get newBucket;

  /// Category
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Where
  ///
  /// In en, this message translates to:
  /// **'Where'**
  String get where;

  /// Min Value
  ///
  /// In en, this message translates to:
  /// **'Min Value'**
  String get minValue;

  /// Liquidity
  ///
  /// In en, this message translates to:
  /// **'Liquidity'**
  String get liquidity;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
