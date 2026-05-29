// Substitua o arquivo home_screen.dart por esta versão com o controle em lote implementado:

import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/bucket_card.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/domain/data/enum/chart_filter.dart';
import 'package:stack_money/domain/data/models/chart_filter_state.dart';
import 'package:stack_money/domain/data/models/history.dart';
import 'package:stack_money/domain/data/models/bucket.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/parameter_service.dart';
import 'package:stack_money/features/home/widgets/home_header.dart';
import 'package:stack_money/features/home/widgets/patrimonial_hud.dart';
import 'package:stack_money/features/home/widgets/telemetry_filter_bar.dart';
import 'package:stack_money/features/home/widgets/telemetry_line_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier<bool>(false);

  ChartFilterState _chartFilter = const ChartFilterState(
    filter: ChartFilter.threeMonths,
  );

  List<Bucket> _realParameters = [];
  List<History> _realHistoryTimeline = [];

  bool _isLoading = true;
  bool _hasError = false;

  // 🗝️ REGISTRO DE CHAVES GLOBAIS PARA CONTROLAR OS POTES EM LOTE
  final List<GlobalKey<BucketCardState>> _bucketKeys = [];

  // Estado visual do botão mestre (True = Próxima ação vai expandir tudo | False = Vai fechar tudo)
  bool _masterExpandState = true;

  @override
  void initState() {
    super.initState();
    _loadFirebaseDashboardData();
  }

  Future<void> _loadFirebaseDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final results = await Future.wait([
        ParameterManagementService().getActiveParameters(),
        HistoryManagementService().getConsolidatedHistory(),
      ]);

      setState(() {
        _realParameters = results[0] as List<Bucket>;
        _realHistoryTimeline = results[1] as List<History>;

        // 🛠️ Cria uma chave global única para cada pote carregado do Firebase
        _bucketKeys.clear();
        for (var i = 0; i < _realParameters.length; i++) {
          _bucketKeys.add(GlobalKey<BucketCardState>());
        }

        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG_SYSTEM [HomeScreen]: Critical fail -> $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  // 🎯 DISPARA O COMANDO EM LOTE NAS GLOBAL KEYS
  void _toggleAllBuckets() {
    for (var key in _bucketKeys) {
      key.currentState?.setExpandedState(_masterExpandState);
    }
    setState(() {
      _masterExpandState = !_masterExpandState;
    });
  }

  // 🔄 REGRA DE SINCRONIA INVERSA: Só altera o botão se TODOS mudarem juntos
  void _checkGlobalCardsState() {
    if (_bucketKeys.isEmpty) return;

    // Varre as chaves lendo o booleano de expansão interno de cada State público
    final states = _bucketKeys.map((k) => k.currentState?.isExpanded ?? false).toList();

    final allOpen = states.every((expanded) => expanded == true);
    final allClosed = states.every((expanded) => expanded == false);

    if (allOpen && _masterExpandState == true) {
      setState(() {
        _masterExpandState = false; // Se todos abriram manualmente, o mestre vira comando de fechar
      });
    } else if (allClosed && _masterExpandState == false) {
      setState(() {
        _masterExpandState = true; // Se todos fecharam manualmente, o mestre vira comando de abrir
      });
    }
  }

  @override
  void dispose() {
    _visibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      body: SafeArea(
        bottom: true,
        top: false,
        child: CustomScrollView(
          slivers: [
            HomeHeader(visibilityNotifier: _visibilityNotifier),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              sliver: SliverToBoxAdapter(
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  color: Colors.transparent,
                  child: _buildBodyContent(l10n),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBodyContent(AppLocalizations l10n) {
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(
            color: StackMoneyTheme.cyanNeon,
            backgroundColor: StackMoneyTheme.surface,
            strokeWidth: 3,
          ),
        ),
      );
    }

    if (_hasError || _realHistoryTimeline.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_maybe_outlined, color: StackMoneyTheme.magentaNeon, size: 48),
              const SizedBox(height: 16),
              Text(l10n.systemLinkFailed, style: TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadFirebaseDashboardData,
                child: Text(l10n.retryHandshake, style: TextStyle(color: StackMoneyTheme.cyanNeon, fontFamily: 'Orbitron')),
              )
            ],
          ),
        ),
      );
    }

    final latestAudit = _realHistoryTimeline.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        PatrimonialHud(
          totalAmount: latestAudit.total,
          liquidityAmount: latestAudit.immediateLiquidityTotal,
          visibilityListenable: _visibilityNotifier,
        ),

        const SizedBox(height: 20),

        ValueListenableBuilder<bool>(
          valueListenable: _visibilityNotifier,
          builder: (context, isVisible, child) {
            return StackMoneyCard(
              title: l10n.telemetryStream,
              visibilityNotifier: _visibilityNotifier,
              children: [
                SizedBox(
                  height: 220,
                  child: TelemetryLineChart(
                    rawHistoryData: _realHistoryTimeline,
                    filterState: _chartFilter,
                    isSystemVisible: isVisible,
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(color: Colors.white10, height: 1),
                const SizedBox(height: 16),
                TelemetryFilterBar(
                  currentState: _chartFilter,
                  isEnabled: isVisible,
                  onFilterChanged: (newState) {
                    setState(() {
                      _chartFilter = newState;
                    });
                  },
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        // 🎛️ RÓTULO TÁTICO DA SEÇÃO + ÍCONE MESTRE COLORIDO REATIVO
        ValueListenableBuilder<bool>(
          valueListenable: _visibilityNotifier,
          builder: (context, isVisible, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.allocationBuckets,
                  style: TextStyle(
                    color: StackMoneyTheme.mutedGrey,
                    fontFamily: 'Orbitron',
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                // Exibe o ícone de controle apenas se o app estiver aberto no protocolo stealth
                if (isVisible)
                  IconButton(
                    onPressed: _toggleAllBuckets,
                    icon: Icon(
                      _masterExpandState ? Icons.unfold_more : Icons.unfold_less,
                      // Ciano se a próxima ação for Expandir tudo | Magenta se for Colapsar tudo!
                      color: _masterExpandState ? StackMoneyTheme.cyanNeon : StackMoneyTheme.magentaNeon,
                      size: 22,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: 16),

        // 🔋 RENDERIZAÇÃO DOS POTES COM VINCULAÇÃO DE CHAVES GLOBAIS
        ...List.generate(_realParameters.length, (index) {
          final param = _realParameters[index];
          return BucketCard(
            key: _bucketKeys[index], // 👈 Injeta a GlobalKey correspondente ao pote
            parameter: param,
            historyList: _realHistoryTimeline,
            visibilityNotifier: _visibilityNotifier,
            onStateChanged: _checkGlobalCardsState, // Escuta as interações manuais do usuário
          );
        }),

        const SizedBox(height: 40),
      ],
    );
  }
}