import 'package:flutter/material.dart';
import 'package:flutter_ai_toolkit/flutter_ai_toolkit.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: StackMoneyTheme.background,
        automaticallyImplyLeading: false,
        title: Text('Personal CFO'),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_rounded),
        ),
      ),
      body: LlmChatView(
        suggestions: AiConfig.suggestions,
        style: LlmChatViewStyle(
          backgroundColor: StackMoneyTheme.background,
          addButtonStyle: ActionButtonStyle(
            iconColor: StackMoneyTheme.background,
            iconDecoration: BoxDecoration(
              color: StackMoneyTheme.magentaNeon,
              borderRadius: BorderRadius.circular(AppSizes.avatarRadius),
            )
          ),
          submitButtonStyle: ActionButtonStyle(
              iconColor: StackMoneyTheme.background,
              iconDecoration: BoxDecoration(
                color: StackMoneyTheme.cyanNeon,
                borderRadius: BorderRadius.circular(AppSizes.avatarRadius),
              )
          ),
          recordButtonStyle: ActionButtonStyle(
              iconColor: StackMoneyTheme.background,
              iconDecoration: BoxDecoration(
                color: StackMoneyTheme.cyanNeon,
                borderRadius: BorderRadius.circular(AppSizes.avatarRadius),
              )
          ),
          chatInputStyle: ChatInputStyle(
            hintText: AiConfig.messageHint,
            hintStyle: textTheme.labelSmall,
            textStyle: textTheme.bodySmall,
            backgroundColor: StackMoneyTheme.background,
            decoration: BoxDecoration(
              color: StackMoneyTheme.surface,
              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
              boxShadow: [
                BoxShadow(
                  color: StackMoneyTheme.cyanNeon.withValues(alpha: 0.07),
                  blurRadius: AppSizes.x10,
                  spreadRadius: 3,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
          ),
        ),
        provider: GeminiProvider(
          model: GenerativeModel(
            model: AiConfig.geminiModel,
            apiKey: AiKey.key,
            systemInstruction: Content.system(AiConfig.systemInstruction),
          ),
        ),
        welcomeMessage: AiConfig.welcomeMessage,
      ),
    );
  }
}
