import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/l10n/app_localizations.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/core/widgets/glassmorphism_effect.dart';
import 'package:stack_money/data/helper/asset_name.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/chat_thread_model.dart';
import 'package:stack_money/features/personal_cfo/manager/personal_cfo_manager.dart';
import 'package:stack_money/features/personal_cfo/widgets/ai_message.dart';
import 'package:stack_money/features/personal_cfo/widgets/chat_header.dart';
import 'package:stack_money/features/personal_cfo/widgets/send_message.dart';
import 'package:stack_money/features/personal_cfo/widgets/user_message.dart';

class PersonalCfoScreen extends StatefulWidget {
  final ChatThreadModel? thread;

  static const route = '/personal_cfo';

  const PersonalCfoScreen({this.thread, super.key});

  @override
  State<PersonalCfoScreen> createState() => _PersonalCfoScreenState();
}

class _PersonalCfoScreenState extends State<PersonalCfoScreen> {
  late final PersonalCfoManager _manager;

  @override
  void initState() {
    super.initState();
    _manager = PersonalCfoManager(widget.thread, context);
  }

  @override
  void dispose() {
    _manager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final textTheme = Theme.of(context).textTheme;

    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isKeyboardActive = keyboardHeight > 0;
    final double topSafeArea = MediaQuery.of(context).padding.top;
    final double bottomSafeArea = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// Background
          Positioned.fill(
            child: Image.asset(
              AssetName.chatBackground,
              fit: BoxFit.fill,
              opacity: const AlwaysStoppedAnimation(0.55),
            ),
          ),

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
                  top:
                      topSafeArea +
                      AppSizes.cfoAppBarHeight +
                      AppSizes.sizedBoxMedium,
                  bottom:
                      bottomSafeArea +
                      AppSizes.cfoSendBarHeight +
                      keyboardHeight,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];

                  if (msg.sender.isUser) {
                    return UserMessage(msg: msg);
                  }

                  return AiMessage(
                    msg: msg,
                    handleActionResponse: _manager.handleActionResponse,
                  );
                },
              );
            },
          ),

          /// Send Message
          Positioned(
            left: AppSizes.min,
            right: AppSizes.min,
            bottom: isKeyboardActive
                ? keyboardHeight + AppSizes.cfoKeyboardOpen
                : bottomSafeArea,
            child: ValueListenableBuilder(
              valueListenable: _manager.isStreaming,
              builder: (_, isStreaming, _) {
                return SendMessage(
                  controller: _manager.messageController,
                  isStreaming: isStreaming,
                  onSend: _manager.sendMessage,
                );
              },
            ),
          ),

          /// Chat Header
          Positioned(
            left: AppSizes.min,
            right: AppSizes.min,
            top: topSafeArea,
            child: ValueListenableBuilder(
              valueListenable: _manager.titleController,
              builder: (_, title, _) {
                return ChatHeader(
                  title: title.text,
                  saveTitle: _manager.changeTitle,
                );
              },
            ),
          ),

          /// Header SafeArea
          Positioned(
            top: 0,
            right: 0,
            left: 0,
            child: GlassmorphismEffect(
              borderRadius: 0,
              containerHeight: topSafeArea - AppSizes.x2,
              backgroundColor: StackMoneyTheme.background,
              borderColor: StackMoneyTheme.background,
              child: SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}
