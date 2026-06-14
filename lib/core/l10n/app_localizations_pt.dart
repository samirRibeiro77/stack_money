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
  String get allocation => 'Alocação: ';

  @override
  String get min => 'Min: ';

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

  @override
  String get auditLogs => 'Auditoria';

  @override
  String get securityBiometricReason =>
      'Autentique-se para visualizar seus dados sensíveis e saldos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get bucketsConfig => 'Configuração das Caixinhas';

  @override
  String get newBucket => 'Adicionar nova caixinha';

  @override
  String get category => 'Categoria';

  @override
  String get where => 'Onde';

  @override
  String get minValue => 'Valor minimo';

  @override
  String get liquidity => 'Liquidez';

  @override
  String get percentSignal => '%';

  @override
  String get plansConfig => 'Configurações dos planos';

  @override
  String get newPlan => 'Adicionar novo plano';

  @override
  String get activePlan => 'Plano ativo';

  @override
  String get setActive => 'Tornar ativo';

  @override
  String get grossRevenue => 'Salário bruto';

  @override
  String get remainingRest => 'Restante livre';

  @override
  String get baseSalary => 'Salário base';

  @override
  String get type => 'Tipo';

  @override
  String get brlCurrency => 'R\$';

  @override
  String get day => 'Dia';

  @override
  String converted(Object value) {
    return 'Convertido: $value';
  }

  @override
  String get notAvailable => 'N/A';

  @override
  String get mandatoryDeductions => 'Deduções em folha';

  @override
  String get deductionName => 'Nome da dedução';

  @override
  String get target => 'Alvo';

  @override
  String get rule => 'Regra';

  @override
  String deducted(Object value) {
    return 'Deduzido: $value';
  }

  @override
  String get totalNet => 'Liquido total';

  @override
  String get totalRest => 'Total restante:';

  @override
  String netDay(Object value) {
    return 'Dia $value';
  }

  @override
  String netValue(Object value) {
    return 'Liquido: $value';
  }

  @override
  String rest(Object value) {
    return 'Resto: $value';
  }

  @override
  String get systemOverflow => '[ LIMITE_EXCEDIDO ]';

  @override
  String overflowBy(Object value) {
    return 'Acima (- $value)';
  }
}
