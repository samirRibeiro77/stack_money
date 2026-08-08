import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/widgets/card_initialize_slot.dart';
import 'package:stack_money/core/widgets/title_text.dart';
import 'package:stack_money/features/chats/manager/ai_chat_manager.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key = const ValueKey(route)});

  static const route = '/chats';

  @override
  State<ChatsScreen> createState() => _AiChatsScreenState();
}

class _AiChatsScreenState extends State<ChatsScreen> {
  final _manager = AiChatManager();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TitleText('Ai Chats'),
        const SizedBox(height: AppSizes.sizedBoxMedium),
        CardInitializeSlot(
          'New chat',
          onTap: () => _manager.initializeNewBucketSlot(context),
        ),
      ],
    );
  }
}
