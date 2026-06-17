import 'package:flutter/material.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/features/buckets/manager/buckets_manager.dart';
import 'package:stack_money/features/buckets/widgets/bucket_card.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/bucket.dart';

class BucketControlScreen extends StatefulWidget {
  const BucketControlScreen({super.key = const ValueKey(route)});

  static const route = '/buckets_control';

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
          builder: (context, bucketList, child) {
            return ValueListenableBuilder<Set<String>>(
              valueListenable: _manager.expandedIdsNotifier,
              builder: (context, expandedIds, _) {
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
    return Column(
      children: [
        ExpandableHeader(
          title: l10n.bucketsConfig,
          validation: _manager.expandState,
          toggle: _manager.toggleAllBuckets,
          activeIcon: Icons.unfold_more,
          inactiveIcon: Icons.unfold_less,
        ),
        const SizedBox(height: AppSizes.x6),

        CardInitializeSlot(
          l10n.newBucket,
          onTap: _manager.initializeNewBucketSlot,
        ),
        const SizedBox(height: AppSizes.x3),

        ...List.generate(bucketList.length, (index) {
          final bucket = bucketList[index];

          final isCardExpanded = expandedIds.contains(bucket.id);

          return BucketCard(
            key: ValueKey(bucket.id),
            bucket: bucket,
            isExpanded: isCardExpanded,
            onHeaderTap: () => _manager.toggleBucketExpansion(bucket.id),
            confirmDismiss: _manager.showTerminalConfirmDialog,
            onDismissed: _manager.purgeBucket,
            onAutoSave: _manager.saveBucketToFirebase,
          );
        }),
      ],
    );
  }
}
