import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/bucket_card.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/domain/data/models/history.dart';
import 'package:stack_money/domain/data/models/parameters.dart';
import 'package:stack_money/features/home/widgets/home_header.dart';
import 'package:stack_money/features/home/widgets/patrimonial_hud.dart';
import 'package:stack_money/features/home/widgets/telemetry_chart_state.dart';
import 'package:stack_money/features/home/widgets/telemetry_filter_bar.dart';
import 'package:stack_money/features/home/widgets/telemetry_line_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const route = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mudamos temporariamente para TRUE para testar se o gráfico inicializa sem o bug de achatamento
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier<bool>(true);

  ChartFilterState _chartFilter = const ChartFilterState(
    filter: ChartFilter.threeMonths,
  );

  final List<Parameter> _mockParameters = [
    Parameter(category: "Investimento", where: "Nomad Setup", minValue: 15000.0, isImmediateLiquidity: true),
    Parameter(category: "Reserva", where: "Emergency Buffer", minValue: 20000.0, isImmediateLiquidity: false),
    Parameter(category: "Investimento", where: "Compass 4x4", minValue: 60000.0, isImmediateLiquidity: true),
    Parameter(category: "Reserva", where: "Safety Wallet", minValue: 100000.0, isImmediateLiquidity: false),
  ];

  late final List<History> _mockLegacyHistory;

  @override
  void initState() {
    super.initState();

    final idNomad = "Investimento_NomadSetup";
    final idEmergency = "Reserva_EmergencyBuffer";
    final idCompass = "Investimento_Compass4x4";
    final idSafety = "Reserva_SafetyWallet";

    _mockLegacyHistory = [
      History.fromJson("2026_01_05", {
        "date": "2026-01-05",
        "total": 254200.46,
        "immediateLiquidityTotal": 3200.0,
        "transactions": {
          idNomad: {"id": idNomad, "category": "Investimento", "where": "Nomad Setup", "actualValue": 16000.0},
          idEmergency: {"id": idEmergency, "category": "Reserva", "where": "Emergency Buffer", "actualValue": 22000.0},
          idCompass: {"id": idCompass, "category": "Investimento", "where": "Compass 4x4", "actualValue": 55000.0},
          idSafety: {"id": idSafety, "category": "Reserva", "where": "Safety Wallet", "actualValue": 105000.0}
        }
      }),
      History.fromJson("2026_02_20", {
        "date": "2026-02-20",
        "total": 244520.94,
        "immediateLiquidityTotal": 1500.0,
        "transactions": {
          idNomad: {"id": idNomad, "category": "Investimento", "where": "Nomad Setup", "actualValue": 14000.0},
          idEmergency: {"id": idEmergency, "category": "Reserva", "where": "Emergency Buffer", "actualValue": 21000.0},
          idCompass: {"id": idCompass, "category": "Investimento", "where": "Compass 4x4", "actualValue": 52000.0},
          idSafety: {"id": idSafety, "category": "Reserva", "where": "Safety Wallet", "actualValue": 98000.0}
        }
      }),
      History.fromJson("2026_05_22", {
        "date": "2026-05-22",
        "total": 223025.27,
        "immediateLiquidityTotal": 3287.76,
        "transactions": {
          idNomad: {"id": idNomad, "category": "Investimento", "where": "Nomad Setup", "actualValue": 15500.0},
          idEmergency: {"id": idEmergency, "category": "Reserva", "where": "Emergency Buffer", "actualValue": 20500.0},
          idCompass: {"id": idCompass, "category": "Investimento", "where": "Compass 4x4", "actualValue": 48000.0},
          idSafety: {"id": idSafety, "category": "Reserva", "where": "Safety Wallet", "actualValue": 95000.0}
        }
      }),
    ];
  }

  @override
  void dispose() {
    _visibilityNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                // 🛠️ FIX PROTOCOLO DE ISOLAMENTO DE TELA PRETA:
                // Envelopamos a Column num Container com largura total estrita
                child: Container(
                  width: MediaQuery.of(context).size.width - 32,
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Força a coluna a ocupar o espaço mínimo necessário
                    children: [
                      // 1. HUD Principal
                      PatrimonialHud(
                        totalAmount: 223025.27,
                        liquidityAmount: 3287.76,
                        visibilityListenable: _visibilityNotifier,
                      ),

                      const SizedBox(height: 20),

                      // 2. Telemetria Global unificada dentro de um bloco com tamanho rígido
                      StackMoneyCard(
                        title: 'TELEMETRY_STREAM',
                        visibilityNotifier: _visibilityNotifier,
                        children: [
                          // Forçamos um SizedBox com altura cravada em volta do gráfico para o fl_chart não bugar
                          SizedBox(
                            height: 220,
                            child: TelemetryLineChart(
                              rawHistoryData: _mockLegacyHistory,
                              filterState: _chartFilter,
                              isSystemVisible: true, // Forçado true para o teste visual inicial
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white10, height: 1),
                          const SizedBox(height: 16),
                          TelemetryFilterBar(
                            currentState: _chartFilter,
                            isEnabled: true,
                            onFilterChanged: (newState) {
                              setState(() {
                                _chartFilter = newState;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'ALLOCATION_BUCKETS',
                        style: TextStyle(
                          color: StackMoneyTheme.mutedGrey,
                          fontFamily: 'Orbitron',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Renderização dos cards de Potes
                      ..._mockParameters.map(
                            (param) => BucketCard(
                          parameter: param,
                          historyList: _mockLegacyHistory,
                          visibilityNotifier: _visibilityNotifier,
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}