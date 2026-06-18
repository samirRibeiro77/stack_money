import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class ContributionSprintManager {
  final BucketManagementService _service = BucketManagementService();

  final ValueNotifier<List<Bucket>> _bucketsNotifier = ValueNotifier([]);
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);

  Map<String, double> _lastKnownValues = {};

  final nameController = TextEditingController();
  final whereController = TextEditingController();
  final minValueController = TextEditingController();
  final actualValueController = TextEditingController();

  ValueListenable<List<Bucket>> get bucketsNotifier => _bucketsNotifier;
  ValueListenable<int> get currentIndexNotifier => _currentIndexNotifier;
  ValueListenable<bool> get isLoadingNotifier => _isLoadingNotifier;

  List<Bucket> get buckets => _bucketsNotifier.value;
  int get currentIndex => _currentIndexNotifier.value;

  Future<void> initializeSprint() async {
    try {
      _isLoadingNotifier.value = true;

      final loadedBuckets = await _service.fetch();
      final lastValues = await _service.fetchLastSprintValues();
      for (var t in lastValues) {
        _lastKnownValues[t.id] = t.actualValue;
      }

      _bucketsNotifier.value = loadedBuckets;

      if (loadedBuckets.isNotEmpty) {
        _populateFieldsForIndex(0);
      }
      _isLoadingNotifier.value = false;
    } catch (e) {
      debugPrint('❌ [SPRINT_INITIALIZE_FAIL] -> $e');
      _isLoadingNotifier.value = false;
    }
  }

  double getLastKnownValueForBucket(Bucket bucket) {
    return _lastKnownValues[bucket.id] ?? 0.0;
  }

  void _populateFieldsForIndex(int index) {
    if (index >= 0 && index < buckets.length) {
      final bucket = buckets[index];
      nameController.text = bucket.category;
      whereController.text = bucket.where;
      minValueController.text = StackMoneyString.formatMoney(bucket.minValue);
      actualValueController.text = '';
    }
  }

  /// ➡️ PRÓXIMO PASSO COM SALVAMENTO (Botão do Body)
  void nextStep(BuildContext context) {
    _cacheCurrentStepData();
    _moveForward(context);
  }

  /// ⏭️ 🔥 NOVO: PULAR PASSO SEM SALVAR NADA (Botão da AppBar)
  void skipStep(BuildContext context) {
    _moveForward(context);
  }

  /// Auxiliar interno de navegação para a frente
  void _moveForward(BuildContext context) {
    if (currentIndex < buckets.length - 1) {
      _currentIndexNotifier.value = currentIndex + 1;
      _populateFieldsForIndex(currentIndex);
    } else {
      _processSprintCompletion(context);
    }
  }

  /// ⬅️ RETROCEDER PASSO
  void previousStep() {
    if (currentIndex > 0) {
      _cacheCurrentStepData();
      _currentIndexNotifier.value = currentIndex - 1;
      _populateFieldsForIndex(currentIndex);
    }
  }

  void _cacheCurrentStepData() {
    if (buckets.isEmpty) return;

    final bucket = buckets[currentIndex];
    final double lastValue = getLastKnownValueForBucket(bucket);

    final double verifiedActualValue = actualValueController.text.isNotEmpty
        ? StackMoneyNumber.parseMoneyStringToDouble(actualValueController.text)
        : lastValue;

    final double verifiedMinValue = minValueController.text.isNotEmpty
        ? StackMoneyNumber.parseMoneyStringToDouble(minValueController.text)
        : bucket.minValue;

    buckets[currentIndex] = Bucket(
      id: bucket.id,
      category: nameController.text.trim(),
      where: whereController.text.trim(),
      minValue: verifiedMinValue,
      isImmediateLiquidity: bucket.isImmediateLiquidity,
    );

    final String txId = '${buckets[currentIndex].category.replaceAll(' ', '')}_${buckets[currentIndex].where.replaceAll(' ', '')}';
    _lastKnownValues[txId] = verifiedActualValue;
  }

  Future<void> _processSprintCompletion(BuildContext context) async {
    try {
      _isLoadingNotifier.value = true;

      final List<Transaction> compiledTransactions = [];
      double netWorthTotal = 0.0;
      double netWorthLiquidity = 0.0;

      for (final bucket in buckets) {
        final String txId = '${bucket.category.replaceAll(' ', '')}_${bucket.where.replaceAll(' ', '')}';
        final double finalValue = _lastKnownValues[txId] ?? 0.0;

        compiledTransactions.add(
          Transaction(
            category: bucket.category,
            where: bucket.where,
            actualValue: finalValue,
          ),
        );

        netWorthTotal += finalValue;
        if (bucket.isImmediateLiquidity) {
          netWorthLiquidity += finalValue;
        }
      }

      await _service.executeContributionSprint(
        updatedBuckets: buckets,
        transactions: compiledTransactions,
        totalNetWorth: netWorthTotal,
        totalLiquidity: netWorthLiquidity,
      );

      if (context.mounted) {
        _isLoadingNotifier.value = false;
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('❌ [SPRINT_COMMIT_FAIL] -> $e');
      _isLoadingNotifier.value = false;
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
  }
}