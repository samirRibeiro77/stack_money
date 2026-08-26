import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/features/chats/widgets/chat_card.dart';

class ChatDismissibleCard extends StatelessWidget {
  const ChatDismissibleCard(this.chat, {required this.confirmDismiss, this.onDismissed, required this.onTap, super.key});

  final ChatThreadModel chat;
  final ConfirmDismissCallback confirmDismiss;
  final DismissDirectionCallback? onDismissed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return Dismissible(
      key: Key(chat.id),
      direction: isSecureActive
          ? DismissDirection.none
          : DismissDirection.horizontal,
      confirmDismiss: confirmDismiss,
      onDismissed: onDismissed,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10),
        decoration: BoxDecoration(
          color: chat.isArchived
              ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.12)
              : StackMoneyTheme.mutedGrey.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: chat.isArchived
                ? StackMoneyTheme.cyanNeon.withValues(alpha: 0.3)
                : StackMoneyTheme.mutedGrey.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerLeft,
        child: Icon(
          chat.isArchived ? Icons.unarchive_rounded : Icons.archive_rounded,
          color: chat.isArchived
              ? StackMoneyTheme.cyanNeon
              : StackMoneyTheme.mutedGrey,
          size: AppSizes.x12,
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSizes.x3),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.x10),
        decoration: BoxDecoration(
          color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppSizes.radiusSmall),
          border: Border.all(
            color: StackMoneyTheme.magentaNeon.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete_sweep_rounded,
          color: StackMoneyTheme.magentaNeon,
          size: AppSizes.x12,
        ),
      ),
      child: ChatCard(chat, onTap: onTap),
    );
  }
}
