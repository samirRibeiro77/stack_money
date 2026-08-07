import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/result.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/domain/service/bucket_service.dart';
import 'package:stack_money/domain/service/history_service.dart';
import 'package:stack_money/features/error/error_screen.dart';

class ContributionSprintManager {
  final _bucketService = BucketManagementService();
  final _historyService = HistoryManagementService();

  final ValueNotifier<List<Bucket>> _bucketsNotifier = ValueNotifier([]);
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final _minIsPositive = ValueNotifier(true);
  final _actualIsPositive = ValueNotifier(true);
  final _isLiquid = ValueNotifier(true);

  final _lastKnownValues = <String, double>{};
  final _originalValues = <String, double>{};

  final nameController = TextEditingController();
  final whereController = TextEditingController();
  final minValueController = TextEditingController();
  final actualValueController = TextEditingController();

  ValueListenable<List<Bucket>> get bucketsNotifier => _bucketsNotifier;

  ValueListenable<int> get currentIndexNotifier => _currentIndexNotifier;

  ValueListenable<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Bucket> get buckets => _bucketsNotifier.value;

  int get currentIndex => _currentIndexNotifier.value;

  Future<void> initializeSprint(BuildContext context) async {
    try {
      _isLoadingNotifier.value = true;

      final loadedBuckets = AppCoordinator.instance.buckets.value;
      final lastSprintResult = await _historyService.fetchLastSprintValues();
      switch (lastSprintResult) {
        case Success(data: final lastSprintValues):
          for (var t in lastSprintValues) {
            _originalValues[t.bucketId] = t.actualValue;
            _lastKnownValues[t.bucketId] = t.actualValue;
          }
        case Failure(exception: final error):
          throw error;
      }

      loadedBuckets.sort((a, b) => b.name.compareTo(a.name));
      _bucketsNotifier.value = loadedBuckets;

      if (loadedBuckets.isNotEmpty) {
        _populateFieldsForIndex(0);
      }
      _isLoadingNotifier.value = false;
    } on StackMoneyException catch (e) {
      if (context.mounted) {
        context.go(ErrorScreen.route, extra: e);
      }
    } catch (e, stack) {
      if (context.mounted) {
        context.go(
          ErrorScreen.route,
          extra: StackMoneyException(
            message: 'Error initializing sprint',
            scope: ExceptionScope.business,
            exception: e as Exception,
            stackTrace: stack,
          ),
        );
      }
    }
  }

  double getLastKnownValueForBucket(Bucket bucket) {
    return _lastKnownValues[bucket.id] ?? 0.0;
  }

  void _populateFieldsForIndex(int index) {
    if (index >= 0 && index < buckets.length) {
      final bucket = buckets[index];

      nameController.text = bucket.category ?? '';
      whereController.text = bucket.where;
      minValueController.text = '';
      actualValueController.text = '';
      _minIsPositive.value = bucket.minValue >= 0;
      _actualIsPositive.value = true;
      _isLiquid.value = bucket.isImmediateLiquidity;
    }
  }

  void minIsPositive(bool value) {
    _minIsPositive.value = value;
  }

  void changeActualSign() {
    _actualIsPositive.value = !_actualIsPositive.value;
  }

  void changeLiquidity() {
    _isLiquid.value = !_isLiquid.value;
  }

  void nextStep(BuildContext context) {
    _cacheCurrentStepData();
    _moveForward(context);
  }

  void _moveForward(BuildContext context) {
    if (currentIndex < buckets.length - 1) {
      _currentIndexNotifier.value = currentIndex + 1;
      _populateFieldsForIndex(currentIndex);
    } else {
      _showSprintConfirmationDialog(context);
    }
  }

  void previousStep(BuildContext context) {
    if (currentIndex > 0) {
      _cacheCurrentStepData();
      _currentIndexNotifier.value = currentIndex - 1;
      _populateFieldsForIndex(currentIndex);
    } else {
      Navigator.of(context).pop();
    }
  }

  void _cacheCurrentStepData() {
    if (buckets.isEmpty) return;

    final bucket = buckets[currentIndex];
    final double lastValue = getLastKnownValueForBucket(bucket);

    double verifiedActualValue = actualValueController.text.isNotEmpty
        ? StackMoneyNumber.parseMoneyStringToDouble(actualValueController.text)
        : lastValue;

    if (!_actualIsPositive.value) {
      verifiedActualValue = -verifiedActualValue;
    }

    double verifiedMinValue = minValueController.text.isNotEmpty
        ? StackMoneyNumber.parseMoneyStringToDouble(minValueController.text)
        : 0.0;

    if (!_minIsPositive.value) {
      verifiedMinValue = -verifiedMinValue;
    }

    buckets[currentIndex] = bucket.copyWith(
      category: nameController.text,
      where: whereController.text,
      minValue: bucket.minValue + verifiedMinValue,
      isImmediateLiquidity: _isLiquid.value,
    );

    _lastKnownValues[bucket.id] = verifiedActualValue;
  }

  /// 🔥 INTERCEPTOR DE SEGURANÇA: Monta o relatório compacto e invoca o seu SmDialog
  void _showSprintConfirmationDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final List<Transaction> compiledTransactions = [];
    double netWorthTotal = 0.0;
    double netWorthLiquidity = 0.0;
    final List<String> deltaLogs = [];

    for (final bucket in buckets) {
      final double finalValue = _lastKnownValues[bucket.id] ?? 0.0;
      final double oldValue = _originalValues[bucket.id] ?? 0.0;

      compiledTransactions.add(
        Transaction.create(
          bucket.id,
          finalValue,
          category: bucket.category,
          where: bucket.where,
        ),
      );

      netWorthTotal += finalValue;
      if (bucket.isImmediateLiquidity) {
        netWorthLiquidity += finalValue;
      }

      final bucketChange = l10n.confirmContributionSprintNoteLine(
        StackMoneyString.formatTitle(bucket.name),
        StackMoneyString.formatMoney(finalValue, symbol: true),
        StackMoneyString.formatMoney(oldValue, symbol: true),
      );
      if (finalValue > oldValue) {
        deltaLogs.add('${l10n.arrowUp} $bucketChange');
      } else if (finalValue < oldValue) {
        deltaLogs.add('${l10n.arrowDown} $bucketChange');
      }
    }

    final messageText = l10n.confirmContributionSprintMessage(
      StackMoneyString.formatMoney(netWorthLiquidity, symbol: true),
      StackMoneyString.formatMoney(netWorthTotal, symbol: true),
    );

    final String noteText = deltaLogs.isNotEmpty
        ? l10n.confirmContributionSprintNote(deltaLogs.join('\n'))
        : StackMoneyString.formatTitle(l10n.noChangesDetected);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SmDialog(
        title: l10n.confirmContributionSprintTitle,
        message: messageText,
        note: noteText,
        color: StackMoneyTheme.cyanNeon,
        onDeny: () => Navigator.of(dialogContext).pop(),
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          _executeFirebaseCommit(
            context,
            compiledTransactions,
            netWorthTotal,
            netWorthLiquidity,
          );
        },
      ),
    );
  }

  /// Execução final da persistência isolada
  Future<void> _executeFirebaseCommit(
    BuildContext context,
    List<Transaction> transactions,
    double total,
    double liquidity,
  ) async {
    final navigatorContext = Navigator.of(context);
    try {
      _isLoadingNotifier.value = true;
      await _bucketService.executeContributionSprint(
        updatedBuckets: buckets,
        transactions: transactions,
        totalNetWorth: total,
        totalLiquidity: liquidity,
      );
    } catch (e, stack) {
      StackMoneyException(
        message: 'Sprint commit failed',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'transactionsQty': transactions.length},
        stackTrace: stack,
      );
    } finally {
      _isLoadingNotifier.value = false;
      if (navigatorContext.mounted) {
        navigatorContext.pop();
      }
    }
  }

  void dispose() {
    nameController.dispose();
    whereController.dispose();
    minValueController.dispose();
    actualValueController.dispose();
    _bucketsNotifier.dispose();
    _currentIndexNotifier.dispose();
    _isLoadingNotifier.dispose();
    _minIsPositive.dispose();
    _actualIsPositive.dispose();
    _isLiquid.dispose();
  }
}
