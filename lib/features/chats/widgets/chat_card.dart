import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/stack_money_string.dart';
import 'package:stack_money/core/helpers/time_ago_formatter.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/security_provider.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/security_text.dart';
import 'package:stack_money/core/widgets/sm_card.dart';
import 'package:stack_money/data/enum/security_type.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';

class ChatCard extends StatelessWidget {
  const ChatCard(this.chat, {required this.onTap, super.key});

  final ChatThreadModel chat;
  final VoidCallback onTap;

  Color get shadowColor {
    if (chat.isArchived) return StackMoneyTheme.magentaNeon;
    return StackMoneyTheme.cyanNeon;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;
    final isSecureActive = SecurityProvider.isSecureOf(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSizes.x3),
      child: GestureDetector(
        onTap: isSecureActive ? null : onTap,
        child: SmCard(
          shadowColor: shadowColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SecurityText(
                    StackMoneyString.formatTitle(chat.title),
                    activeColor: StackMoneyTheme.cyanNeon,
                    style: textTheme.titleSmall,
                    type: SecurityType.systemLocked,
                  ),
                  SecurityText(
                    TimeAgoFormatter.format(l10n, chat.updatedAt),
                    activeColor: StackMoneyTheme.magentaNeon,
                    style: textTheme.labelSmall,
                  ),
                ],
              ),
              const Divider(),
              if (!isSecureActive) ...[
                Text(
                  chat.lastMessage,
                  style: textTheme.bodySmall?.copyWith(
                    color: StackMoneyTheme.mutedGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (isSecureActive) ...[
                SecurityText('', style: textTheme.bodySmall),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
