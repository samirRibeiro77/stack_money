import 'package:flutter/material.dart';
import 'package:stack_money/core/providers/bucket_card_scope.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/models/bucket.dart';
import 'package:stack_money/features/bucket_card/manager/bucket_card_manager.dart';
import 'package:stack_money/features/bucket_card/widgets/bucket_card_background.dart';
import 'package:stack_money/features/bucket_card/widgets/bucket_card_form.dart';
import 'package:stack_money/features/bucket_card/widgets/bucket_card_header.dart';
import 'package:stack_money/features/bucket_card/widgets/bucket_card_saving_animation.dart';

class BucketCard extends StatefulWidget {
  final Bucket bucket;
  final bool isExpanded;
  final VoidCallback onHeaderTap;
  final VoidCallback? onDismissed;

  const BucketCard({
    required this.bucket,
    required this.isExpanded,
    required this.onHeaderTap,
    this.onDismissed,
    super.key,
  });

  @override
  State<BucketCard> createState() => _BucketCardState();
}

class _BucketCardState extends State<BucketCard> {
  late final BucketCardManager _cardManager;

  @override
  void initState() {
    super.initState();
    _cardManager = BucketCardManager(widget.bucket);
  }

  @override
  void dispose() {
    _cardManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return BucketCardScope(
      manager: _cardManager,
      child: Dismissible(
        key: Key(widget.bucket.id),
        direction: isSecureActive
            ? DismissDirection.none
            : DismissDirection.endToStart,
        confirmDismiss: (_) => _cardManager.confirmPurge(context),
        onDismissed: (_) async {
          await _cardManager.purgeSelf();
          if (widget.onDismissed != null) widget.onDismissed!();
        },
        background: const BucketCardBackground(),
        child: BucketCardSavingAnimation(
          child: SmCard(
            removePadding: true,
            child: Column(
              children: [
                BucketCardHeader(
                  isExpanded: widget.isExpanded,
                  onHeaderTap: widget.onHeaderTap,
                ),
                if (widget.isExpanded && !isSecureActive) ...[
                  const Divider(color: StackMoneyTheme.background, height: 1),
                  const BucketCardForm(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
