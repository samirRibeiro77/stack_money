import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/features/personal_cfo/manager/personal_cfo_manager.dart';
import 'package:stack_money/features/personal_cfo/widgets/ai_message.dart';
import 'package:stack_money/features/personal_cfo/widgets/chat_header.dart';
import 'package:stack_money/features/personal_cfo/widgets/send_message.dart';
import 'package:stack_money/features/personal_cfo/widgets/user_message.dart';

class PersonalCfoScreen extends StatefulWidget {
  static const route = '/personal_cfo';

  const PersonalCfoScreen({super.key});

  @override
  State<PersonalCfoScreen> createState() => _PersonalCfoScreenState();
}

class _PersonalCfoScreenState extends State<PersonalCfoScreen> {
  final TextEditingController _textController = TextEditingController();
  late final PersonalCfoManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = PersonalCfoManager();
    _manager.init();
  }

  @override
  void dispose() {
    _textController.dispose();
    _manager.dispose();
    super.dispose();
  }

  void _handleSend(AppLocalizations l10n) {
    final text = _textController.text;
    if (text.trim().isEmpty) return;

    _manager.sendMessage(l10n, text);
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final bool isKeyboardActive = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      body: Stack(
        children: [
          /// Stream Messages
          ValueListenableBuilder<List<ChatMessageModel>>(
            valueListenable: _manager.messagesNotifier,
            builder: (_, messages, _) {
              if (messages.isEmpty) {
                return Center(
                  child: Text(
                    l10n.chatEmpty,
                    textAlign: TextAlign.center,
                    style: textTheme.labelLarge,
                  ),
                );
              }

              return ListView.builder(
                controller: _manager.scrollController,
                padding: EdgeInsets.only(
                  top: AppSizes.cfoContentTopPadding,
                  bottom: AppSizes.cfoContentBottomPadding,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  final isUser = msg.sender == MessageSender.user;

                  if (isUser) {
                    return UserMessage(msg: msg);
                  }

                  return AiMessage(msg: msg, handleActionResponse: (_, _) {});
                },
              );
            },
          ),

          /// Send Message
          Positioned(
            left: AppSizes.min,
            right: AppSizes.min,
            bottom: isKeyboardActive
                ? AppSizes.cfoKeyboardOpen
                : AppSizes.cfoKeyboardClosed,
            child: SendMessage(
              controller: _textController,
              onSend: () => _handleSend(l10n),
            ),
          ),

          /// Chat Header
          SafeArea(
            child: Positioned(
              left: AppSizes.min,
              right: AppSizes.min,
              top: AppSizes.x10,
              child: ValueListenableBuilder(
                valueListenable: _manager.activeThreadNotifier,
                builder: (_, thread, _) {
                  return ChatHeader(
                    title: thread?.title ?? l10n.newChat,
                    saveTitle: (_) {},
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
