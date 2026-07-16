import 'dart:async';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/helpers/stack_money_number.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class BucketCardManager {
  final _bucketService = BucketManagementService();

  late Bucket _bucket;

  Bucket get bucket => _bucket;

  final isSaving = ValueNotifier(false);
  final isNegative = ValueNotifier(false);
  final isImmediateLiquidity = ValueNotifier(false);

  late final TextEditingController whereController;
  late final TextEditingController categoryController;
  late final TextEditingController minValueController;

  late final FocusNode whereFocus;
  late final FocusNode categoryFocus;
  late final FocusNode minValueFocus;

  Timer? _debounceTimer;

  BucketCardManager(Bucket initialBucket) {
    _bucket = initialBucket;
    isImmediateLiquidity.value = _bucket.isImmediateLiquidity;
    isNegative.value = _bucket.minValue < 0;

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
    isNegative.value = !isNegative.value;
    _triggerSaveNow();
  }

  void updateLiquidity(bool value) {
    isImmediateLiquidity.value = value;
    _triggerSaveNow();
  }

  Future _triggerSaveNow() async {
    double doubleValue = StackMoneyNumber.parseMoneyStringToDouble(
      minValueController.text,
    );

    if (isNegative.value) doubleValue = -doubleValue;

    final updated = _bucket.copyWith(
      where: whereController.text,
      category: categoryController.text,
      minValue: doubleValue,
      isImmediateLiquidity: isImmediateLiquidity.value,
    );

    if (_bucket.equalsTo(updated)) return;

    _bucket = updated;
    isSaving.value = true;

    await _bucketService
        .save(updated)
        .then((_) {
          SmLogger.info('Auto-save executed on Database: ${updated.id}');
        })
        .catchError((e, stack) {
          StackMoneyException(
            message: 'Failed to auto-save bucket dynamically',
            scope: ExceptionScope.business,
            payload: {'exception': e, 'bucket': updated},
            stackTrace: stack,
          );
        });

    await Future.delayed(const Duration(milliseconds: 500));
    isSaving.value = false;
  }

  Future<bool> confirmPurge(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    if (!_bucket.isDeletable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Bucket still have values and can\'t be deleted'),
        ),
      );
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
    isSaving.dispose();
    isNegative.dispose();
    isImmediateLiquidity.dispose();
  }
}
