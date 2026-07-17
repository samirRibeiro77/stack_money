import 'dart:async';
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
import 'package:stack_money/data/enum/snack_bar_type.dart';
import 'package:stack_money/data/enum/value_sign.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class BucketCardManager {
  final _bucketService = BucketManagementService();

  late Bucket _bucket;

  Bucket get bucket => _bucket;

  final _isSaving = ValueNotifier(false);
  final _isImmediateLiquidity = ValueNotifier(false);
  final _minValueSign = ValueNotifier(ValueSign.positive);
  final _techColor = ValueNotifier(StackMoneyTheme.cyanNeon);

  ValueListenable<bool> get isSaving => _isSaving;

  ValueListenable<bool> get isImmediateLiquidity => _isImmediateLiquidity;

  ValueListenable<ValueSign> get minValueSign => _minValueSign;

  ValueListenable<Color> get techColor => _techColor;

  late final TextEditingController whereController;
  late final TextEditingController categoryController;
  late final TextEditingController minValueController;

  late final FocusNode whereFocus;
  late final FocusNode categoryFocus;
  late final FocusNode minValueFocus;

  Timer? _debounceTimer;

  BucketCardManager(Bucket initialBucket) {
    _bucket = initialBucket;
    _isImmediateLiquidity.value = _bucket.isImmediateLiquidity;
    _minValueSign.value = ValueSign.define(_bucket.minValue);
    _techColor.value = _bucket.minValue >= 0
        ? StackMoneyTheme.cyanNeon
        : StackMoneyTheme.magentaNeon;

    whereController = TextEditingController(text: _bucket.where);
    categoryController = TextEditingController(text: _bucket.category);
    minValueController = TextEditingController(
      text: StackMoneyString.formatMoney(_bucket.minValue.abs()),
    );

    whereFocus = FocusNode();
    categoryFocus = FocusNode();
    minValueFocus = FocusNode();

    whereFocus.addListener(() => _onFocusChange(whereFocus));
    categoryFocus.addListener(() => _onFocusChange(categoryFocus));
    minValueFocus.addListener(() => _onFocusChange(minValueFocus));

    whereController.addListener(_onTextChanged);
    categoryController.addListener(_onTextChanged);
    minValueController.addListener(_onTextChanged);
  }

  void _onFocusChange(FocusNode focusNode) {
    if (!focusNode.hasFocus) {
      _triggerSaveNow();
    }
  }

  void _onTextChanged() {
    _scheduleDebouncedSave();
  }

  void _scheduleDebouncedSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
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

    final updated = _bucket.copyWith(
      where: whereController.text,
      category: categoryController.text,
      minValue: doubleValue,
      isImmediateLiquidity: isImmediateLiquidity.value,
    );

    if (_bucket.equalsTo(updated)) return;

    _bucket = updated;
    _isSaving.value = true;

    await _bucketService
        .save(updated)
        .then((_) {
          SmLogger.info('Auto-save executed on Database: ${updated.id}');
        })
        .catchError((e, stack) {
          StackMoneyException(
            message: 'Failed to auto-save bucket dynamically',
            scope: ExceptionScope.business,
            payload: {'exception': e, 'bucket': updated.toJson()},
            stackTrace: stack,
          );
        });

    await Future.delayed(const Duration(milliseconds: 500));
    _isSaving.value = false;
  }

  Future<bool> confirmPurge(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_bucket.isDeletable) {
      SmSnackBar(
        message: l10n.failDeleteBucketWithValue,
        type: SnackBarType.error,
      ).show(context);
      return false;
    }

    final result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => SmDialog(
        message: l10n.deleteBucketMessage,
        content: _bucket.name.isEmpty ? l10n.newBucket : _bucket.name,
        note: l10n.deleteBucketNote,
        onCancel: () => Navigator.of(dialogContext).pop(false),
        onConfirm: () => Navigator.of(dialogContext).pop(true),
      ),
    );

    return result ?? false;
  }

  Future purgeSelf() async {
    await _bucketService
        .delete(_bucket.id)
        .then((_) {
          SmLogger.info('Purge completed successfully for ID: ${_bucket.id}');
        })
        .catchError((e, stack) {
          StackMoneyException(
            message: 'Failed to delete bucket from card context',
            scope: ExceptionScope.business,
            payload: {'id': _bucket.id, 'exception': e},
            stackTrace: stack,
          );
        });
  }

  void dispose() {
    _debounceTimer?.cancel();
    whereController.dispose();
    categoryController.dispose();
    minValueController.dispose();
    whereFocus.dispose();
    categoryFocus.dispose();
    minValueFocus.dispose();
    _isSaving.dispose();
    _minValueSign.dispose();
    _isImmediateLiquidity.dispose();
    _techColor.dispose();
  }
}
