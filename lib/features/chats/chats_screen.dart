import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/helpers/time_ago_formatter.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/providers/app_coordinator.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/features/chats/manager/chats_manager.dart';
import 'package:stack_money/features/chats/widgets/chat_dismissible_card.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key = const ValueKey(route)});

  static const route = '/chats';

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  late final ChatsManager _manager;

  Future<bool?> _confirmDismiss(
    DismissDirection direction,
    ChatThreadModel chat,
  ) async {
    if (direction == DismissDirection.endToStart) {
      final result = await _manager.showTerminalConfirmDialog(chat.title);
      if (result == true) {
        await _manager.purgeChatThread(chat.id);
      }
      return result;
    } else {
      _manager.toggleArchiveThread(chat);
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    _manager = ChatsManager(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExpandableHeader(
          title: l10n.plansConfig,
          validation: _manager.showArchivedNotifier,
          toggle: _manager.toggleShowArchived,
          activeIcon: Icons.archive_outlined,
          inactiveIcon: Icons.unarchive_outlined,
          activeColor: StackMoneyTheme.magentaNeon,
          inactiveColor: StackMoneyTheme.cyanNeon,
        ),
        const SizedBox(height: AppSizes.sizedBoxMedium),
        CardInitializeSlot(
          l10n.newChat,
          onTap: () => _manager.initializeNewChat(context),
        ),
        const SizedBox(height: AppSizes.sizedBoxMedium),
        ValueListenableBuilder(
          valueListenable: AppCoordinator.instance.chats,
          builder: (_, allThreads, _) {
            return ValueListenableBuilder(
              valueListenable: _manager.showArchivedNotifier,
              builder: (_, showArchived, _) {
                final filteredThreads = allThreads
                    .where((p) => showArchived ? true : !p.isArchived)
                    .toList();

                return Column(
                  children: List.generate(filteredThreads.length, (index) {
                    final thread = filteredThreads[index];

                    return ChatDismissibleCard(
                      thread,
                      onTap: () => _manager.openThread(context, thread.id),
                      confirmDismiss: (direction) =>
                          _confirmDismiss(direction, thread),
                    );
                  }),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
