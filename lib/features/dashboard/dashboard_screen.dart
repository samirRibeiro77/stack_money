import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/bucket_card.dart';
import 'package:stack_money/core/widgets/stack_money_card.dart';
import 'package:stack_money/data/enum/chart_filter.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/chart_filter_state.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/domain/service/parameter_service.dart';
import 'package:stack_money/features/dashboard/widgets/patrimonial_hud.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_filter_bar.dart';
import 'package:stack_money/features/dashboard/widgets/telemetry_line_chart.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.securityMode, super.key});

  static const route = '/dashboard';

  final ValueListenable<bool> securityMode;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  ChartFilterState _chartFilter = const ChartFilterState(
    filter: ChartFilter.threeMonths,
  );

  List<Bucket> _realParameters = [];
  List<History> _realHistoryTimeline = [];

  bool _isLoading = true;
  bool _hasError = false;

  final List<GlobalKey<BucketCardState>> _bucketKeys = [];
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

  void _toggleAllBuckets() {
    for (var key in _bucketKeys) {
      key.currentState?.setExpandedState(_masterExpandState);
    }
    setState(() {
      _masterExpandState = !_masterExpandState;
    });
  }

  void _checkGlobalCardsState() {
    if (_bucketKeys.isEmpty) return;

    final states = _bucketKeys
        .map((k) => k.currentState?.isExpanded ?? false)
        .toList();

    final allOpen = states.every((expanded) => expanded == true);
    final allClosed = states.every((expanded) => expanded == false);

    if (allOpen && _masterExpandState == true) {
      setState(() => _masterExpandState = false);
    } else if (allClosed && _masterExpandState == false) {
      setState(() => _masterExpandState = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    // 🔄 CORREÇÃO: Retornamos um Box tradicional (Padding) em vez de SliverPadding!
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: _buildBodyContent(l10n, textTheme),
    );
  }

  Widget _buildBodyContent(AppLocalizations l10n, TextTheme textTheme) {
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
              const Icon(
                Icons.gpp_maybe_outlined,
                color: StackMoneyTheme.magentaNeon,
                size: AppSizes.x24,
              ),
              const SizedBox(height: AppSizes.x8),
              Text(
                StackMoneyString.formatTitle(l10n.systemLinkFailed),
                style: textTheme.headlineMedium?.copyWith(
                  color: StackMoneyTheme.magentaNeon,
                ),
              ),
              const SizedBox(height: AppSizes.x4),
              TextButton(
                onPressed: _loadFirebaseDashboardData,
                child: Text(
                  StackMoneyString.formatTitle(l10n.retryHandshake),
                  style: textTheme.titleMedium?.copyWith(
                    color: StackMoneyTheme.cyanNeon,
                  ),
                ),
              ),
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
        // 🔐 Vinculado diretamente ao sinalizador global de privacidade
        PatrimonialHud(
          totalAmount: latestAudit.total,
          liquidityAmount: latestAudit.immediateLiquidityTotal,
          securityMode: widget.securityMode,
        ),

        const SizedBox(height: AppSizes.x10),

        ValueListenableBuilder<bool>(
          valueListenable: widget.securityMode,
          builder: (context, isVisible, child) {
            return StackMoneyCard(
              title: l10n.telemetryStream,
              securityMode: widget.securityMode,
              children: [
                SizedBox(
                  height: 220,
                  child: TelemetryLineChart(
                    rawHistoryData: _realHistoryTimeline,
                    filterState: _chartFilter,
                    isSystemVisible: isVisible,
                  ),
                ),
                const SizedBox(height: AppSizes.x6),
                const Divider(),
                const SizedBox(height: AppSizes.x8),
                TelemetryFilterBar(
                  currentState: _chartFilter,
                  isEnabled: isVisible,
                  onFilterChanged: (newState) =>
                      setState(() => _chartFilter = newState),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: AppSizes.x12),

        ValueListenableBuilder<bool>(
          valueListenable: widget.securityMode,
          builder: (context, isVisible, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  StackMoneyString.formatTitle(l10n.allocationBuckets),
                  style: textTheme.labelLarge?.copyWith(
                    fontWeight: AppTypography.weightBold,
                    letterSpacing: 1.5,
                  ),
                ),
                if (isVisible)
                  IconButton(
                    onPressed: _toggleAllBuckets,
                    icon: Icon(
                      _masterExpandState
                          ? Icons.unfold_more
                          : Icons.unfold_less,
                      color: _masterExpandState
                          ? StackMoneyTheme.cyanNeon
                          : StackMoneyTheme.magentaNeon,
                      size: AppSizes.x10,
                    ),
                  ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSizes.x8),

        ...List.generate(_realParameters.length, (index) {
          final param = _realParameters[index];
          return BucketCard(
            key: _bucketKeys[index],
            parameter: param,
            historyList: _realHistoryTimeline,
            securityMode: widget.securityMode,
            onStateChanged: _checkGlobalCardsState,
          );
        }),

        const SizedBox(height: AppSizes.navBarContentPadding),
      ],
    );
  }
}
