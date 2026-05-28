// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appName => 'Stack Money';

  @override
  String get appNameTwoLines => 'Stack\nMoney';

  @override
  String get loginWithGoogle => 'Entrar com o Google';

  @override
  String get unknow => 'Desconhecido';

  @override
  String get netWorth => 'Patrimônio';

  @override
  String get systemLocked => 'SISTEMA_TRAVADO';

  @override
  String get telemetryStream => 'Telemetria';

  @override
  String get hiddenValues => '••••••';

  @override
  String get liquidityBuffer => 'Liquidez imediata';

  @override
  String get allocationBuckets => 'Caixinhas';

  @override
  String allocation(Object value) {
    return 'Aloc: $value%';
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
  String get oneYear => '1A';

  @override
  String get custom => 'Filtro';

  @override
  String customLabel(Object end, Object start) {
    return '$start a $end';
  }

  @override
  String get noData => 'Sem dados';

  @override
  String get systemLinkFailed => 'Falha ao carregar sistema';

  @override
  String get retryHandshake => 'Tentar novamente';
}
