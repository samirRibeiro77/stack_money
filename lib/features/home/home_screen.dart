import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/bucket_card.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/domain/data/enum/chart_filter.dart';
import 'package:stack_money/domain/data/models/chart_filter_state.dart';
import 'package:stack_money/domain/data/models/history.dart';
import 'package:stack_money/domain/data/models/parameters.dart';
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
  // Inicializa camuflado por padrão seguindo o protocolo Stealth tático
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier<bool>(false);

  ChartFilterState _chartFilter = const ChartFilterState(
    filter: ChartFilter.threeMonths,
  );

  // Listas reais que alimentarão o ecossistema vindas do Firebase
  List<Parameter> _realParameters = [];
  List<History> _realHistoryTimeline = [];

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFirebaseDashboardData();
  }

  // DISPARA A CARGA EM PARALELO VIA ONE-SHOT SNAPSHOT
  Future<void> _loadFirebaseDashboardData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Roda as duas queries simultaneamente para otimizar performance
      final results = await Future.wait([
        ParameterManagementService().getActiveParameters(),
        HistoryManagementService().getConsolidatedHistory(),
      ]);

      setState(() {
        _realParameters = results[0] as List<Parameter>;
        _realHistoryTimeline = results[1] as List<History>;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG_SYSTEM [HomeScreen]: Critical fail to load dashboard data -> $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
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

  // GERE OS ESTADOS DE RENDERIZAÇÃO (LOADING, ERROR E DASHBOARD OPERACIONAL)
  Widget _buildBodyContent(AppLocalizations l10n) {
    // 🌌 1. LOADING CIBERNÉTICO
    if (_isLoading) {
      return const SizedBox(
        height: 400,
        child: Center(
          child: CircularProgressIndicator(
            color: StackMoneyTheme.cyanNeon, // Correndo liso no Ciano Neon
            backgroundColor: StackMoneyTheme.surface,
            strokeWidth: 3,
          ),
        ),
      );
    }

    // 🚨 2. EMERGENCY FALLBACK (CASO O BANCO TRAVE)
    if (_hasError || _realHistoryTimeline.isEmpty) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.gpp_maybe_outlined, color: StackMoneyTheme.magentaNeon, size: 48),
              const SizedBox(height: 16),
              const Text(
                'SYSTEM_LINK_FAILED',
                style: TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: _loadFirebaseDashboardData,
                child: const Text('RETRY_HANDSHAKE', style: TextStyle(color: StackMoneyTheme.cyanNeon, fontFamily: 'Orbitron')),
              )
            ],
          ),
        ),
      );
    }

    // 💎 CAPTURA DINAMICAMENTE OS DADOS ATUAIS DA ÚLTIMA AUDITORIA SALVA NO FIREBASE
    final latestAudit = _realHistoryTimeline.last;

    // ⚔️ 3. DASHBOARD TOTALMENTE OPERACIONAL E REAL
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. HUD Principal consumindo dados dinâmicos do banco
        PatrimonialHud(
          totalAmount: latestAudit.total,
          liquidityAmount: latestAudit.immediateLiquidityTotal,
          visibilityListenable: _visibilityNotifier,
        ),

        const SizedBox(height: 20),

        // 2. Telemetria Global unificada dentro do card
        ValueListenableBuilder<bool>(
          valueListenable: _visibilityNotifier,
          builder: (context, isVisible, child) {
            return StackMoneyCard(
              title: 'TELEMETRY_STREAM',
              visibilityNotifier: _visibilityNotifier,
              children: [
                SizedBox(
                  height: 220,
                  child: TelemetryLineChart(
                    rawHistoryData: _realHistoryTimeline, // Linha de tempo real
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
        const SizedBox(height: 16),

        // 🔋 3. RENDERIZAÇÃO REAL DE CADAS UM DOS SEUS POTES
        ..._realParameters.map(
              (param) => BucketCard(
            parameter: param,
            historyList: _realHistoryTimeline, // Passa a timeline real do Firebase
            visibilityNotifier: _visibilityNotifier,
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }
}