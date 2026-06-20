import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/data/models/transaction.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class ContributionSprintManager {
  final BucketManagementService _service = BucketManagementService();

  final ValueNotifier<List<Bucket>> _bucketsNotifier = ValueNotifier([]);
  final ValueNotifier<int> _currentIndexNotifier = ValueNotifier(0);
  final ValueNotifier<bool> _isLoadingNotifier = ValueNotifier(true);
  final _minIsPositive = ValueNotifier(true);
  final _actualIsPositive = ValueNotifier(true);

  final _lastKnownValues = <String, double>{};

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
      minValueController.text = '';
      actualValueController.text = '';
      _minIsPositive.value = bucket.minValue >= 0;
      _actualIsPositive.value = true;
    }
  }

  void minIsPositive(bool value) {
    _minIsPositive.value = value;
  }

  void changeActualSign() {
    _actualIsPositive.value = !_actualIsPositive.value;
  }

  /// ➡️ PRÓXIMO PASSO COM SALVAMENTO (Botão do Body)
  void nextStep(BuildContext context) {
    _cacheCurrentStepData();
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

    buckets[currentIndex] = Bucket(
      id: bucket.id,
      category: nameController.text.trim(),
      where: whereController.text.trim(),
      minValue: bucket.minValue + verifiedMinValue,
      isImmediateLiquidity: bucket.isImmediateLiquidity,
    );

    _lastKnownValues[bucket.id] = verifiedActualValue;
  }

  Future<void> _processSprintCompletion(BuildContext context) async {
    final navigatorContext = Navigator.of(context);
    try {
      _isLoadingNotifier.value = true;

      final List<Transaction> compiledTransactions = [];
      double netWorthTotal = 0.0;
      double netWorthLiquidity = 0.0;

      for (final bucket in buckets) {
        final double finalValue = _lastKnownValues[bucket.id] ?? 0.0;

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
    } catch (e) {
      debugPrint('❌ [SPRINT_COMMIT_FAIL] -> $e');
      _isLoadingNotifier.value = false;
    } finally {
      if (navigatorContext.mounted) {
        _isLoadingNotifier.value = false;
        navigatorContext.pop();
      } else {
        print('Context is not mounted, unable to pop()');
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
  }
}
