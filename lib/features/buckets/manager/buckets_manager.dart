import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stack_money/core/exceptions/exception_scope.dart';
import 'package:stack_money/core/exceptions/stack_money_exception.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/utils/sm_logger.dart';
import 'package:stack_money/core/widgets/sm_dialog.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/domain/service/bucket_service.dart';

class BucketsManager {
  final _bucketService = BucketManagementService();

  final ValueNotifier<List<Bucket>> _bucketDeck = ValueNotifier([]);
  final ValueNotifier<bool> _isLoading = ValueNotifier(true);
  final ValueNotifier<bool> _masterExpandState = ValueNotifier(true);
  final ValueNotifier<Set<String>> _expandedBucketIds = ValueNotifier({});

  ValueListenable<bool> get isLoading => _isLoading;

  ValueListenable<bool> get expandState => _masterExpandState;

  ValueListenable<List<Bucket>> get bucketDeckNotifier => _bucketDeck;

  ValueListenable<Set<String>> get expandedIdsNotifier => _expandedBucketIds;

  List<Bucket> get buckets => _bucketDeck.value;

  Future<void> loadFirebaseBuckets() async {
    try {
      _isLoading.value = true;
      final data = await _bucketService.fetch();
      _bucketDeck.value = data;
      _isLoading.value = false;
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to fetch buckets',
        scope: ExceptionScope.business,
        payload: {'exception': e},
        stackTrace: stack,
      );
      _isLoading.value = false;
    }
  }

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

    final fullList = List<Bucket>.from(_bucketDeck.value);

    for (int i = 0; i < filteredList.length; i++) {
      final updatedBucket = filteredList[i].copyWith(position: i + 1);
      filteredList[i] = updatedBucket;

      final mainIndex = fullList.indexWhere((b) => b.id == updatedBucket.id);
      if (mainIndex != -1) {
        fullList[mainIndex] = updatedBucket;
      }
    }

    _bucketDeck.value = fullList;

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
      final index = _bucketDeck.value.indexWhere(
        (b) => b.id == updatedBucket.id,
      );
      if (index != -1) {
        final updatedList = List<Bucket>.from(_bucketDeck.value);
        updatedList[index] = updatedBucket;
        _bucketDeck.value = updatedList;
      }
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
    final updatedList = List<Bucket>.from(_bucketDeck.value)
      ..insert(0, newBucket);

    _expandedBucketIds.value = currentSet;
    _bucketDeck.value = updatedList;

    saveBucketToFirebase(newBucket);
  }

  Future<void> purgeBucket(String id) async {
    try {
      await _bucketService.delete(id);
      final index = _bucketDeck.value.indexWhere((b) => b.id == id);
      if (index != -1) {
        final updatedList = List<Bucket>.from(_bucketDeck.value);
        updatedList.removeAt(index);

        final currentSet = Set<String>.from(_expandedBucketIds.value)
          ..remove(id);

        _expandedBucketIds.value = currentSet;
        _bucketDeck.value = updatedList;
      }
    } catch (e, stack) {
      StackMoneyException(
        message: 'Failed to delete bucket',
        scope: ExceptionScope.business,
        payload: {'exception': e, 'bucketId': id},
        stackTrace: stack,
      );
      loadFirebaseBuckets();
    }
  }

  void toggleAllBuckets() {
    if (_masterExpandState.value) {
      _expandedBucketIds.value = _bucketDeck.value.map((b) => b.id).toSet();
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
    final index = _bucketDeck.value.indexWhere((b) => b.id == id);
    if (index != -1) {
      final updatedList = List<Bucket>.from(_bucketDeck.value)..removeAt(index);
      final currentSet = Set<String>.from(_expandedBucketIds.value)..remove(id);

      _expandedBucketIds.value = currentSet;
      _bucketDeck.value = updatedList;
    }
  }
}
