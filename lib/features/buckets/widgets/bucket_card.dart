import 'package:flutter/material.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/features/buckets/widgets/bucket_edit_card.dart';

class BucketCard extends StatelessWidget {
  const BucketCard({
    required this.bucket,
    required this.isExpanded,
    required this.onHeaderTap,
    required this.confirmDismiss,
    required this.onDismissed,
    required this.onAutoSave,
    super.key,
  });

  final Bucket bucket;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final Function(String, BuildContext) confirmDismiss;
  final Function(String) onDismissed;
  final Function(Bucket) onAutoSave;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(bucket.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) => confirmDismiss(
        bucket.name,
        context,
      ),
      onDismissed: (direction) => onDismissed(bucket.id),
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: StackMoneyTheme.magentaNeon.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_forever_rounded,
          color: StackMoneyTheme.magentaNeon,
          size: 24,
        ),
      ),
      child: BucketEditCard(
        bucket: bucket,
        isExpanded: isExpanded,
        onHeaderTap: onHeaderTap,
        onAutoSave: onAutoSave,
      ),
    );
  }
}
