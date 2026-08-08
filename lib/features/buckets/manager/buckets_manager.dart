import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class BucketsManager {
  final _bucketService = BucketManagementService();

  final ValueNotifier<bool> _masterExpandState = ValueNotifier(true);
  final ValueNotifier<Set<String>> _expandedBucketIds = ValueNotifier({});

  BucketsManager() {
    final initialExpand =
        !AppCoordinator.instance.user.value.preferences.cardExpand;
    if (_masterExpandState.value != initialExpand) {
      toggleAllBuckets();
    }
  }

  ValueListenable<bool> get expandState => _masterExpandState;

  ValueListenable<Set<String>> get expandedIdsNotifier => _expandedBucketIds;

  void toggleBucketExpansion(String id) {
    SmLogger.debug('Click to open bucket', payload: {'id': id});
    final currentSet = Set<String>.from(_expandedBucketIds.value);
    if (currentSet.contains(id)) {
      currentSet.remove(id);
    } else {
      currentSet.add(id);
    }
    _expandedBucketIds.value = currentSet;
  }

  void reorderFilteredBuckets(
    List<Bucket> filteredList,
    int oldIndex,
    int newIndex,
  ) {
    SmLogger.debug(
      'Reorder buckets',
      payload: {'oldIndex': oldIndex, 'newIndex': newIndex},
    );

    final item = filteredList.removeAt(oldIndex);
    filteredList.insert(newIndex, item);

    final fullList = List<Bucket>.from(AppCoordinator.instance.buckets.value);

    for (int i = 0; i < filteredList.length; i++) {
      final updatedBucket = filteredList[i].copyWith(position: i + 1);
      filteredList[i] = updatedBucket;

      final mainIndex = fullList.indexWhere((b) => b.id == updatedBucket.id);
      if (mainIndex != -1) {
        fullList[mainIndex] = updatedBucket;
      }
    }

    for (final bucket in filteredList) {
      _bucketService.save(bucket).catchError((e, stack) {
        StackMoneyException(
          message: 'Failed to save reordered buckets',
          scope: ExceptionScope.business,
          payload: {'exception': e, 'buckets': bucket},
          stackTrace: stack,
        );
      });
    }
  }

  Future<void> saveBucketToFirebase(Bucket updatedBucket) async {
    try {
      await _bucketService.save(updatedBucket);
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to save bucket',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'bucket': updatedBucket},
        stackTrace: stack,
      );
    }
  }

  void initializeNewBucketSlot() {
    final newBucket = Bucket.empty();

    final currentSet = Set<String>.from(_expandedBucketIds.value)
      ..add(newBucket.id);

    _expandedBucketIds.value = currentSet;

    saveBucketToFirebase(newBucket);
  }

  Future<void> purgeBucket(String id) async {
    try {
      await _bucketService.delete(id);
      final index = AppCoordinator.instance.buckets.value.indexWhere(
        (b) => b.id == id,
      );
      if (index != -1) {
        final updatedList = List<Bucket>.from(
          AppCoordinator.instance.buckets.value,
        );
        updatedList.removeAt(index);

        final currentSet = Set<String>.from(_expandedBucketIds.value)
          ..remove(id);

        _expandedBucketIds.value = currentSet;
      }
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to delete bucket',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'bucketId': id},
        stackTrace: stack,
      );
    }
  }

  void toggleAllBuckets() {
    if (_masterExpandState.value) {
      _expandedBucketIds.value = AppCoordinator.instance.buckets.value
          .map((b) => b.id)
          .toSet();
    } else {
      _expandedBucketIds.value = {};
    }
    _masterExpandState.value = !_masterExpandState.value;
  }

  Future<bool?> showTerminalConfirmDialog(
    String bucketName,
    BuildContext context,
  ) {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => SmDialog(
        message: l10n.deleteBucketMessage,
        content: bucketName,
        note: l10n.deleteBucketNote,
        onCancel: () => Navigator.of(context).pop(false),
        onConfirm: () => Navigator.of(context).pop(true),
      ),
    );
  }

  void removeBucketFromLocalList(String id) {
    final index = AppCoordinator.instance.buckets.value.indexWhere(
      (b) => b.id == id,
    );
    if (index != -1) {
      final currentSet = Set<String>.from(_expandedBucketIds.value)..remove(id);

      _expandedBucketIds.value = currentSet;
    }
  }
}
