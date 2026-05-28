import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/domain/data/models/history.dart';
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
  final ValueNotifier<bool> _visibilityNotifier = ValueNotifier<bool>(false);
  ChartFilterState _chartFilter = const ChartFilterState(filter: ChartFilter.threeMonths);

  // Seus dados reais do CSV para o teste visual
  final List<History> _mockLegacyHistory = [
    History.fromJson("2026_01_05", {"date": "2026-01-05", "total": 254200.46, "transactions": {}}),
    History.fromJson("2026_01_20", {"date": "2026-01-20", "total": 259444.36, "transactions": {}}),
    History.fromJson("2026_02_11", {"date": "2026-02-11", "total": 262249.14, "transactions": {}}),
    History.fromJson("2026_02_20", {"date": "2026-02-20", "total": 244520.94, "transactions": {}}),
    History.fromJson("2026_03_05", {"date": "2026-03-05", "total": 247412.97, "transactions": {}}),
    History.fromJson("2026_03_20", {"date": "2026-03-20", "total": 248615.36, "transactions": {}}),
    History.fromJson("2026_04_02", {"date": "2026-04-02", "total": 254765.75, "transactions": {}}),
    History.fromJson("2026_04_20", {"date": "2026-04-20", "total": 261582.84, "transactions": {}}),
    History.fromJson("2026_05_05", {"date": "2026-05-05", "total": 257744.98, "transactions": {}}),
    History.fromJson("2026_05_14", {"date": "2026-05-14", "total": 220906.14, "transactions": {}}),
    History.fromJson("2026_05_22", {"date": "2026-05-22", "total": 223025.27, "transactions": {}}),
  ];

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
                child: ValueListenableBuilder<bool>(
                  valueListenable: _visibilityNotifier,
                  builder: (context, isVisible, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. HUD Principal
                        PatrimonialHud(
                          totalAmount: 223025.27,
                          liquidityAmount: 3287.76,
                          visibilityListenable: _visibilityNotifier,
                        ),

                        const SizedBox(height: 20),

                        // 🛠️ 2. UNIFIED COMBAT DECK (Gráfico + Filtros dentro do Card Base)
                        StackMoneyCard(
                          title: 'TELEMETRY_STREAM',
                          visibilityNotifier: _visibilityNotifier,
                          children: [
                            TelemetryLineChart(
                              rawHistoryData: _mockLegacyHistory,
                              filterState: _chartFilter,
                              isSystemVisible: isVisible,
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
                        ),

                        const SizedBox(height: 800), // Espaçador tático
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}