import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_reorderable_list.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/features/bucket_card/bucket_card.dart';
import 'package:stack_money/features/buckets/manager/buckets_manager.dart';

class BucketControlScreen extends StatefulWidget {
  const BucketControlScreen({super.key = const ValueKey(route)});

  static const route = '/buckets';

  @override
  State<BucketControlScreen> createState() => _BucketControlScreenState();
}

class _BucketControlScreenState extends State<BucketControlScreen> {
  final _manager = BucketsManager();

  @override
  void initState() {
    super.initState();
    _manager.loadFirebaseBuckets();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder<bool>(
      valueListenable: _manager.isLoading,
      builder: (_, isLoading, _) {
        if (isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: StackMoneyTheme.cyanNeon,
              backgroundColor: StackMoneyTheme.surface,
            ),
          );
        }

        return ValueListenableBuilder<List<Bucket>>(
          valueListenable: _manager.bucketDeckNotifier,
          builder: (_, bucketList, _) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: _manager.expandedIdsNotifier,
              builder: (_, expandedIds, _) {
                return _buildBucketsContent(l10n, bucketList, expandedIds);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBucketsContent(
    AppLocalizations l10n,
    List<Bucket> bucketList,
    Set<String> expandedIds,
  ) {
    final sortedBuckets = List<Bucket>.from(bucketList);
    sortedBuckets.sort((a, b) => a.position.compareTo(b.position));

    return SingleChildScrollView(
      child: Column(
        children: [
          ExpandableHeader(
            title: l10n.bucketsConfig,
            validation: _manager.expandState,
            toggle: _manager.toggleAllBuckets,
          ),
          const SizedBox(height: AppSizes.sizedBoxMedium),

          CardInitializeSlot(
            l10n.newBucket,
            onTap: _manager.initializeNewBucketSlot,
          ),
          const SizedBox(height: AppSizes.sizedBoxSmall),

          SmReorderableList(
            items: sortedBuckets,
            onReorder: (oldIdx, newIdx) =>
                _manager.reorderFilteredBuckets(sortedBuckets, oldIdx, newIdx),
            itemBuilder: (context, bucket, index) {
              final isCardExpanded = expandedIds.contains(bucket.id);
              return BucketCard(
                key: ValueKey(bucket.id),
                bucket: bucket,
                isExpanded: isCardExpanded,
                onHeaderTap: () => _manager.toggleBucketExpansion(bucket.id),
                onDismissed: () => _manager.removeBucketFromLocalList(
                  bucket.id,
                ), // Apenas atualiza a listagem local
              );
            },
            feedbackChildBuilder: (_, bucket, _) => BucketCard(
              bucket: bucket,
              isExpanded: false,
              onHeaderTap: () {},
            ),
            draggingChildBuilder: (_, bucket, _) {
              final isCardExpanded = expandedIds.contains(bucket.id);
              return BucketCard(
                bucket: bucket,
                isExpanded: isCardExpanded,
                onHeaderTap: () {},
              );
            },
          ),
        ],
      ),
    );
  }
}
