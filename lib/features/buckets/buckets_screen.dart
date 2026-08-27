import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/core/widgets/sm_reorderable_list.dart';
import 'package:stack_money/features/bucket_card/bucket_card.dart';
import 'package:stack_money/features/buckets/manager/buckets_manager.dart';

class BucketControlScreen extends StatefulWidget {
  const BucketControlScreen({super.key = const ValueKey(route)});

  static const route = '/buckets';

  @override
  State<BucketControlScreen> createState() => _BucketControlScreenState();
}

class _BucketControlScreenState extends State<BucketControlScreen> {
  late final BucketsManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = BucketsManager(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ValueListenableBuilder(
      valueListenable: AppCoordinator.instance.buckets,
      builder: (_, fbBuckets, _) {
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

              ValueListenableBuilder(
                valueListenable: _manager.expandedIdsNotifier,
                builder: (_, expandedIds, _) {
                  final buckets = fbBuckets;
                  buckets.sort((a, b) => a.position.compareTo(b.position));

                  return SmReorderableList(
                    items: buckets,
                    onReorder: (oldIdx, newIdx) => _manager
                        .reorderFilteredBuckets(buckets, oldIdx, newIdx),
                    itemBuilder: (_, bucket, _) {
                      final isCardExpanded = expandedIds.contains(bucket.id);
                      return BucketCard(
                        key: ValueKey(bucket.id),
                        bucket: bucket,
                        isExpanded: isCardExpanded,
                        onHeaderTap: () =>
                            _manager.toggleBucketExpansion(bucket.id),
                        onDismissed: () =>
                            _manager.removeBucketFromLocalList(bucket.id),
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
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
