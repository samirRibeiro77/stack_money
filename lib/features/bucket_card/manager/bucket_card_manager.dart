import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/core/widgets/sm_snack_bar.dart';
import 'package:stack_money/data/enum/bucket_actions.dart';
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/enum/value_sign.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class BucketCardManager {
  final _bucketService = BucketManagementService();

  final _bucket = ValueNotifier(Bucket.empty());
  late final BuildContext _context;

  final _isSaving = ValueNotifier(false);
  final _isImmediateLiquidity = ValueNotifier(false);
  final _minValueSign = ValueNotifier(ValueSign.positive);
  final _techColor = ValueNotifier(StackMoneyTheme.cyanNeon);
  final _dateColor = ValueNotifier(StackMoneyTheme.cyanNeon);
  final _hasTarget = ValueNotifier(false);

  ValueListenable<bool> get isSaving => _isSaving;

  ValueListenable<bool> get isImmediateLiquidity => _isImmediateLiquidity;

  ValueListenable<ValueSign> get minValueSign => _minValueSign;

  ValueListenable<Color> get techColor => _techColor;

  ValueListenable<Color> get dateColor => _dateColor;

  ValueListenable<bool> get hasTarget => _hasTarget;

  ValueListenable<Bucket> get bucket => _bucket;

  final whereController = TextEditingController(text: '');
  final categoryController = TextEditingController(text: '');
  final minValueController = TextEditingController(text: '');
  final targetValueController = TextEditingController(text: '');
  final targetDateController = TextEditingController(text: '');

  final whereFocus = FocusNode();
  final categoryFocus = FocusNode();
  final minValueFocus = FocusNode();
  final targetValueFocus = FocusNode();
  final targetDateFocus = FocusNode();

  Timer? _debounceTimer;

  BucketCardManager(Bucket initialBucket, this._context) {
    updateBucket(initialBucket);

    whereFocus.addListener(() => _onFocusChange(whereFocus));
    categoryFocus.addListener(() => _onFocusChange(categoryFocus));
    minValueFocus.addListener(() => _onFocusChange(minValueFocus));
    targetValueFocus.addListener(() => _onFocusChange(targetValueFocus));
    targetDateFocus.addListener(() => _onFocusChange(targetDateFocus));

    whereController.addListener(_onTextChanged);
    categoryController.addListener(_onTextChanged);
    minValueController.addListener(_onTextChanged);
    targetValueController.addListener(_onTextChanged);
    targetDateController.addListener(_onTargetDateChanged);
  }

  void updateBucket(Bucket bucket) {
    /// Set bucket
    _bucket.value = bucket;

    /// TargetDate
    final targetDate = StackMoneyString.formatMonthYear(
      _bucket.value.targetDate,
    );

    /// ValueNotifier
    _hasTarget.value = _bucket.value.targetValue != null;
    _isImmediateLiquidity.value = _bucket.value.isImmediateLiquidity;
    _minValueSign.value = ValueSign.define(_bucket.value.minValue);
    _techColor.value = _bucket.value.minValue >= 0
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.magentaNeon;
    _dateColor.value = targetDate.isNotEmpty
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.magentaNeon;

    /// Controllers
    whereController.text = _bucket.value.where;
    categoryController.text = _bucket.value.category ?? '';
    minValueController.text = StackMoneyString.formatMoney(
      _bucket.value.minValue.abs(),
    );
    targetValueController.text = StackMoneyString.formatMoney(
      _bucket.value.targetValue?.abs() ?? 0,
    );
    targetDateController.text = targetDate;
  }

  Stream<Bucket> watchBucket(String id) {
    return _bucketService.watchById(id);
  }

  List<BucketActions> get bucketActions {
    return BucketActions.values.where((a) {
      if (_hasTarget.value) {
        return a != BucketActions.enableTarget;
      } else {
        return a != BucketActions.disableTarget;
      }
    }).toList();
  }

  void handleAction(BucketActions action) {
    switch (action) {
      case BucketActions.enableTarget:
      case BucketActions.disableTarget:
        return _toggleTarget();
    }
  }

  void _toggleTarget() {
    if (_hasTarget.value) {
      _hasTarget.value = false;
    } else {
      _hasTarget.value = true;
      targetValueController.text = '0.0';
      targetDateController.text = '';

      WidgetsBinding.instance.addPostFrameCallback((_) {
        targetValueFocus.requestFocus();
      });
    }

    _triggerSaveNow();
  }

  void _onFocusChange(FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      _triggerSaveNow();
    }
  }

  void _onTextChanged() {
    _scheduleDebouncedSave();
  }

  void _onTargetDateChanged() {
    if (targetDateController.text.isEmpty) {
      _dateColor.value = StackMoneyTheme.cyanNeon;
      return;
    }

    final targetDate = StackMoneyNumber.parseMonthYearToTimestamp(
      targetDateController.text,
    );

    if (targetDate == null) {
      _dateColor.value = StackMoneyTheme.magentaNeon;
    } else {
      _dateColor.value = StackMoneyTheme.cyanNeon;
    }
  }

  void _scheduleDebouncedSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
      _triggerSaveNow();
    });
  }

  void toggleValueSign() {
    _minValueSign.value = _minValueSign.value.change();

    _techColor.value = _minValueSign.value.isNegative
        ? StackMoneyTheme.magentaNeon
        : StackMoneyTheme.cyanNeon;

    _triggerSaveNow();
  }

  void updateLiquidity(bool value) {
    _isImmediateLiquidity.value = value;
    _triggerSaveNow();
  }

  Future _triggerSaveNow() async {
    double doubleValue = StackMoneyNumber.parseMoneyStringToDouble(
      minValueController.text,
    );

    if (minValueSign.value.isNegative) doubleValue = -doubleValue;

    double? targetDoubleValue;
    if (_hasTarget.value) {
      targetDoubleValue = StackMoneyNumber.parseMoneyStringToDouble(
        targetValueController.text,
      );
    }

    Timestamp? targetTimestampDate;
    if (_hasTarget.value) {
      if (_dateColor.value == StackMoneyTheme.magentaNeon) {
        _failedSave();
        return;
      }

      targetTimestampDate = StackMoneyNumber.parseMonthYearToTimestamp(
        targetDateController.text,
      );
    }

    final updated = _bucket.value.copyWith(
      where: whereController.text,
      category: categoryController.text,
      minValue: doubleValue,
      isImmediateLiquidity: isImmediateLiquidity.value,
      targetValue: () => targetDoubleValue,
      targetDate: () => targetTimestampDate,
    );

    if (_bucket.value.equalsTo(updated)) return;

    _bucket.value = updated;
    _isSaving.value = true;

    final saveResult = await _bucketService.save(updated);
    if (!saveResult.isSuccess) {
      _failedSave();
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));
    _isSaving.value = false;
  }

  void _failedSave() {
    if (_context.mounted) {
      final l10n = AppLocalizations.of(_context)!;
      SmSnackBar(
        message: l10n.failedSave,
        type: SnackBarType.error,
      ).show(_context);
    }
    _isSaving.value = false;
  }

  Future<bool> confirmPurge() async {
    final l10n = AppLocalizations.of(_context)!;

    if (!_bucket.value.isDeletable) {
      SmSnackBar(
        message: l10n.failDeleteBucketWithValue,
        type: SnackBarType.error,
      ).show(_context);
      return false;
    }

    final result = await showDialog(
      context: _context,
      barrierDismissible: false,
      builder: (dialogContext) => SmDialog(
        message: l10n.deleteBucketMessage,
        content: _bucket.value.name.isEmpty
            ? l10n.newBucket
            : _bucket.value.name,
        note: l10n.deleteBucketNote,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    return result ?? false;
  }

  Future purgeSelf() async {
    await _bucketService
        .delete(_bucket.value.id)
        .then((_) {
          SmLogger.info(
            'Purge completed successfully for ID: ${_bucket.value.id}',
          );
        })
        .catchError((e, stack) {
          StackMoneyException(
            message: 'Failed to delete bucket from card context',
            scope: ExceptionScope.business,
            payload: {'id': _bucket.value.id, 'exception': e},
            stackTrace: stack,
          );
        });
  }

  void dispose() {
    _debounceTimer?.cancel();
    whereController.dispose();
    categoryController.dispose();
    minValueController.dispose();
    targetValueController.dispose();
    whereFocus.dispose();
    categoryFocus.dispose();
    minValueFocus.dispose();
    targetValueFocus.dispose();
    _isSaving.dispose();
    _minValueSign.dispose();
    _isImmediateLiquidity.dispose();
    _techColor.dispose();
    _hasTarget.dispose();
  }
}
