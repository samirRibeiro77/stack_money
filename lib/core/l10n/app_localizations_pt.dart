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
  String get retry => 'Repetir';

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
  String get newBucket => 'Nova caixinha';

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
  String get newPlan => 'Novo plano';

  @override
  String get activePlan => 'Plano ativo';

  @override
  String get active => 'Ativo';

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
    return 'Acima ($value)';
  }

  @override
  String get newDistributionRule => 'Nova distribuição';

  @override
  String get subcategory => 'Subcategoria';

  @override
  String get percentNet => '% liq';

  @override
  String get percentGross => '% bru';

  @override
  String get copy => 'Copiar';

  @override
  String get share => 'Compartilhar';

  @override
  String get archive => 'Arquivar';

  @override
  String get delete => 'Deletar';

  @override
  String dayX(Object d) {
    return 'D$d';
  }

  @override
  String get lastKnownValue => 'Último valor conhecido:';

  @override
  String get moneySprint => 'Corrida financeira';

  @override
  String get liquid => 'Liquidez';

  @override
  String get invest => 'Investimento';

  @override
  String get addToMin => 'Somar ao min:';

  @override
  String get subToMin => 'Subtrair do min:';

  @override
  String get positiveActualValue => 'Valor atual positivo';

  @override
  String get negativeActualValue => 'Valor atual negativo';

  @override
  String get exit => 'Sair';

  @override
  String get previous => 'Anterior';

  @override
  String get next => 'Próximo';

  @override
  String get finish => 'Terminar';

  @override
  String get systemWarning => 'Aviso do sistema';

  @override
  String get confirm => 'Confirmar';

  @override
  String get deny => 'Negar';

  @override
  String get deletePlanMessage => 'Deseja deletar o plano salarial?';

  @override
  String get deletePlanNote => 'Todos os planejamentos serão deletados.';

  @override
  String get deleteBucketMessage => 'Deseja deletar a caixinha?';

  @override
  String get deleteBucketNote => 'Todas as alocações serão deletadas.';

  @override
  String get deleteInflowMessage => 'Deseja deletar a entrada de salário?';

  @override
  String get deleteInflowNote => 'A entrada salarial será deletada.';

  @override
  String get deletedInflow => 'Entrada salarial deletada';

  @override
  String get deleteOutflowMessage => 'Deseja deletar a dedução?';

  @override
  String get deleteOutflowNote => 'A dedução salarual será deletada.';

  @override
  String get deletedOutflow => 'Dedução em folha deletada';

  @override
  String get deleteDistributionMessage =>
      'Deseja deletar a distribuição salarial?';

  @override
  String get deleteDistributionNote =>
      'Todos os valores dessa distribuição serão distribuidos.';

  @override
  String get deletedDistribution => 'Regra de distribuição deletada';

  @override
  String get undo => 'Desfazer';

  @override
  String get selectRange => 'Selecione o intervalo';

  @override
  String get startDate => 'Inicio';

  @override
  String get endDate => 'Fim';

  @override
  String get confirmContributionSprintTitle => 'Confirmar status';

  @override
  String confirmContributionSprintMessage(Object liquidity, Object netWorth) {
    return '[ RESUMO DE METRICAS ]\nPatrimonio: $netWorth\nLiquido: $liquidity';
  }

  @override
  String confirmContributionSprintNote(Object changes) {
    return '[ MUDANÇAS ]\n$changes';
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
  String get noChangesDetected => 'Nenhuma alteração identificada';

  @override
  String get arrowUp => '▲';

  @override
  String get arrowDown => '▼';

  @override
  String get reorderBuckets => 'Reordenar caixinhas';

  @override
  String get filterByPosition => 'Posição da caixinha';

  @override
  String get filterByName => 'Nome da caixinha';

  @override
  String get filterByActual => 'Maior valor atual';

  @override
  String get filterByMin => 'Menor valor minimo';

  @override
  String get filterByAlloc => 'Alocação na carteira';

  @override
  String get failDeleteBucketWithValue =>
      'Caixinha tem \'VALOR_MINIMO\' preenchido, não pode ser deletada';

  @override
  String get planMoneySprintDay => 'Dia planejado de atualizar seu dinheiro';

  @override
  String get start => 'Começar';

  @override
  String get settings => 'Configurações';

  @override
  String get adminName => 'Nome';

  @override
  String get adminEmail => 'Email';

  @override
  String get logout => 'Sair';

  @override
  String get systemPreferences => 'Preferências de sistema';

  @override
  String get enabled => 'Habilitado';

  @override
  String get disabled => 'Desabilitado';

  @override
  String get securityModeTitle => 'Iniciar no modo seguro';

  @override
  String get securityModeCode => 'SISTEMA.MODO_SEGURO';

  @override
  String get cardExpandTitle => 'Expandir cards por padrão';

  @override
  String get cardExpandCode => 'PAINEL.CARDS_EXPANDIDOS';

  @override
  String get defaultFilterCode => 'PAINEL.FILTRO_PADRÃO';

  @override
  String get exportData => 'Exportar dados';

  @override
  String exportDataPlans(Object qty) {
    return 'Planos: $qty';
  }

  @override
  String exportDataHistory(Object qty) {
    return 'Histórico: $qty';
  }

  @override
  String exportDataBuckets(Object qty) {
    return 'Caixinhas: $qty';
  }

  @override
  String exportDataJsonSize(Object size) {
    return 'Tamanho do JSON: $size';
  }

  @override
  String get exportJsonData => 'Exportar dados JSON';

  @override
  String get rememberLast => 'Ultimo usado';

  @override
  String get settingsChangedTitle => 'Alterações nas config';

  @override
  String settingsChangedMessage(Object qty) {
    return 'Identificamos $qty modificações pendentes nas suas preferências:';
  }

  @override
  String settingsChangedNote(Object code, Object current, Object old) {
    return '• $code:\n   $old ➔ $current\n';
  }

  @override
  String get failedToSignIn => 'Falha ao fazer login';

  @override
  String get failedToSaveUser => 'Falha ao salvar usuário';

  @override
  String get systemCode => 'CORE.SIS';

  @override
  String get initializing => 'Carregando...';

  @override
  String get loadingUser =>
      'AUTENTICANDO: Infiltrando redes e descriptografando perfil de usuário...';

  @override
  String get loadingPlan =>
      'ALOCAÇÃO: Sincronizando matrizes de distribuição salarial...';

  @override
  String get loadingBucket =>
      'COFRES: Consolidando montantes e sub-cofres digitais...';

  @override
  String get loadingHistory =>
      'RASTROS: Reconstituindo logs e histórico de transações na rede...';

  @override
  String get error => 'Erro';

  @override
  String get reload => 'Recarregar o app';

  @override
  String get payload => 'Dados';

  @override
  String get stackTrace => 'Pilha';

  @override
  String get exception => 'Exceção';

  @override
  String get dataMightBeLost =>
      'Alguns dados podem ter sido perdidos ou corrompidos...';

  @override
  String get failedSave => 'Erro ao salvar...';

  @override
  String get failedUpdateLastFilter =>
      'Erro ao atualizar ultimo filtro utilizado...';

  @override
  String get failedInitializingNewSlot => 'Erro ao inicializar um novo slot...';

  @override
  String get failedArchivePlan => 'Erro ao arquivar plano...';

  @override
  String get failedPurgePlan => 'Erro ao excluir plano...';

  @override
  String get planChangedTitle => 'Alterações no plano';

  @override
  String planChangedMessage(Object qty) {
    return 'Identificamos $qty alterações no plano:';
  }

  @override
  String planChangedName(Object current, Object old) {
    return '• Nome:\n   $old ➔ $current\n';
  }

  @override
  String planChangedBaseSalary(Object current, Object old) {
    return '• Salário base:\n   R\\\$$old ➔ R\\\$$current\n';
  }

  @override
  String planChangedItem(Object code, Object current, Object old) {
    return '• $code:\n   $old itens ➔ $current itens\n';
  }

  @override
  String get planChangedIncoming => 'Entradas';

  @override
  String get planChangedOutcoming => 'Saídas';

  @override
  String get planChangedDistribution => 'Distribuições';
}
