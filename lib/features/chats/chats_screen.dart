import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/expandable_header.dart';
import 'package:stack_money/features/chats/manager/chats_manager.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key = const ValueKey(route)});

  static const route = '/chats';

  @override
  State<ChatsScreen> createState() => _AiChatsScreenState();
}

class _AiChatsScreenState extends State<ChatsScreen> {
  final _manager = ChatsManager();

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
          onTap: () => _manager.initializeNewBucketSlot(context),
        ),
      ],
    );
  }
}
