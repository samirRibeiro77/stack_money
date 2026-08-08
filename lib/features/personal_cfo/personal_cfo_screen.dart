import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/helper/ai_key.dart';
import 'package:stack_money/data/models/ai_config.dart';

class PersonalCfoScreen extends StatefulWidget {
  static const route = '/personal_cfo';

  const PersonalCfoScreen({super.key});

  @override
  State<PersonalCfoScreen> createState() => _PersonalCfoScreenState();
}

class _PersonalCfoScreenState extends State<PersonalCfoScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: StackMoneyTheme.background,
        automaticallyImplyLeading: false,
        title: Text('Personal CFO'),
        centerTitle: true,
      ),
      body: LlmChatView(
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
      ),
    );
  }
}
