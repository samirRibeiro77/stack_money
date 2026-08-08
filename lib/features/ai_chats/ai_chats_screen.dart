import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stack_money/data/helper/ai_key.dart';
import 'package:stack_money/data/models/ai_config.dart';

class AiChatsScreen extends StatefulWidget {
  const AiChatsScreen({super.key = const ValueKey(route)});

  static const route = '/ai_chats';

  @override
  State<AiChatsScreen> createState() => _AiChatsScreenState();
}

class _AiChatsScreenState extends State<AiChatsScreen> {
  @override
  Widget build(BuildContext context) {
    return LlmChatView(
      suggestions: AiConfig.suggestions,
      style: LlmChatViewStyle(
        chatInputStyle: ChatInputStyle(
          hintText: AiConfig.messageHint,
          decoration: const BoxDecoration().copyWith(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
      ),
      provider: GeminiProvider(
        model: GenerativeModel(
          model: AiConfig.geminiModel,
          apiKey: AiKey.key,
          systemInstruction: Content.system(
            AiConfig.systemInstruction,
          ),
        ),
      ),
      welcomeMessage: AiConfig.welcomeMessage,
    );
  }
}
