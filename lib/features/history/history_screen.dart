import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/constants/app_typography.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/history.dart';
import 'package:stack_money/domain/service/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.securityMode, super.key});

  static const route = '/history';
  final ValueListenable<bool> securityMode;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<History> _consolidatedDays = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFirebaseHistoryData();
  }

  Future<void> _loadFirebaseHistoryData() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Puxa a lista de snapshots consolidados por data (Documentos do Firebase)
      final logs = await HistoryManagementService().getConsolidatedHistory();

      setState(() {
        // Inverte para exibir o fechamento diário mais recente no topo
        _consolidatedDays = logs.reversed.toList();
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG_SYSTEM [HistoryScreen]: Mismatch structure fail -> $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: _buildHistoryContent(l10n, textTheme),
    );
  }

  Widget _buildHistoryContent(AppLocalizations l10n, TextTheme textTheme) {
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

    if (_hasError || _consolidatedDays.isEmpty) {
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
                onPressed: _loadFirebaseHistoryData,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          StackMoneyString.formatTitle(l10n.auditLogs),
          style: textTheme.labelLarge?.copyWith(
            fontWeight: AppTypography.weightBold,
            letterSpacing: 1.5,
            color: StackMoneyTheme.mutedGrey,
          ),
        ),
        const SizedBox(height: AppSizes.x12),

        // 🛰️ ITERAÇÃO 1: Varre cada documento de dia consolidado (ex: 2026_05_22)
        ..._consolidatedDays.map((historyDay) {
          // Se o documento desse dia não tiver transações internas registradas, pula
          if (historyDay.transactions.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSizes.x6),

              // 📆 Cabeçalho minimalista único para o dia de fechamento
              Text(
                StackMoneyString.formatDate(
                  historyDay.date,
                  showYear: true,
                  hideSameYear: false,
                  fullYear: true,
                ),
                style: textTheme.labelMedium,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Divider(
                  color: StackMoneyTheme.carbonGrey,
                  thickness: 0.5,
                ),
              ),

              // 🛰️ ITERAÇÃO 2: Renderiza todas as transações internas que ocorreram nesse dia específico
              // 🛰️ ITERAÇÃO 2: Acessa os '.values' do Map para transformá-lo em um Iterable!
              ...historyDay.transactions.values.map((tx) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Esquerda: Ícone Tático + Informações (where e category)
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: StackMoneyTheme.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: StackMoneyTheme.carbonGrey,
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              Icons.show_chart,
                              size: 16,
                              color: StackMoneyTheme.cyanNeon,
                            ),
                          ),
                          const SizedBox(width: AppSizes.x6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                StackMoneyString.formatTitle(tx.category),
                                style: textTheme.titleSmall,
                              ),
                              Text(
                                StackMoneyString.formatTitle(tx.where),
                                style: textTheme.bodySmall?.copyWith(
                                  color: StackMoneyTheme.mutedGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Direita: O valor reativo com o Eye Toggle unificado
                      ValueListenableBuilder<bool>(
                        valueListenable: widget.securityMode,
                        builder: (context, isVisible, child) {
                          return Text(
                            isVisible
                                ? StackMoneyString.formatMoney(
                                    doubleValue: tx.actualValue,
                                  )
                                : l10n.hiddenValues,
                            style: textTheme.titleMedium?.copyWith(
                              color: isVisible
                                  ? StackMoneyTheme.platinumSilver
                                  : StackMoneyTheme.mutedGrey,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
              // 💥 ESSENCIAL: Garanta o .toList() no final do .map() para o spread (...) funcionar!,
              const SizedBox(height: AppSizes.x6),
            ],
          );
        }),

        const SizedBox(height: 120),
      ],
    );
  }
}
