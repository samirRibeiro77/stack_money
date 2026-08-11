import 'package:flutter/material.dart';
import 'package:stack_money/core/constants/app_sizes.dart';
import 'package:stack_money/core/theme/theme.dart';
import 'package:stack_money/data/enum/action_status.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/models/chat_message_model.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';
import 'package:stack_money/features/personal_cfo/widgets/ai_message.dart';
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
  final ScrollController _scrollController = ScrollController();

  // Mock de Mensagens Iniciais para Teste de Usabilidade
  List<ChatMessageModel> messages = [
    ChatMessageModel(
      id: '1',
      chatId: 'mock_chat',
      sender: MessageSender.user,
      text:
          'Como posso reorganizar meu aporte para comprar o consórcio sem zerar a reserva?',
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    ChatMessageModel(
      id: '2',
      chatId: 'mock_chat',
      sender: MessageSender.cfoAi,
      text:
          '# Analisando seu plano "CI&T untill Sep" e seus baldes atuais: \n## Header 2\n### Header 3\n\nSe ajustarmos a distribuição do balde `Compass` em **R\$ 300/mês**,você: \n- Mantém _100%_ da sua liquidez imediata intacta.\n\n```dart\nfinal codeExample = \'Code format written in dart to see on the app how it will show...\'\n```',
      timestamp: DateTime.now().subtract(const Duration(minutes: 9)),
      proposedAction: ProposedActionModel(
        id: 'action_1',
        actionType: 'update_bucket',
        title: 'Reajuste Tático de Balde',
        description:
            'Aumentar o valor mínimo do balde "Compass" para R\$ 5.484,04.',
        payload: {
          'bucketId': '98c929a8-337a-48b0-a2a5-0524d7b26788',
          'newValue': 5484.04,
        },
        status: ActionStatus.pending,
      ),
    ),
  ];

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      messages.add(
        ChatMessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          chatId: 'mock_chat',
          sender: MessageSender.user,
          text: text,
          timestamp: DateTime.now(),
        ),
      );
    });

    _textController.clear();
    _scrollToBottom();
  }

  void _handleActionResponse(String messageId, ActionStatus newStatus) {
    setState(() {
      final index = messages.indexWhere((m) => m.id == messageId);
      if (index != -1 && messages[index].proposedAction != null) {
        final updatedAction = messages[index].proposedAction!.copyWith(
          status: newStatus,
        );
        messages[index] = messages[index].copyWith(
          proposedAction: updatedAction,
        );
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: StackMoneyTheme.background,
      appBar: AppBar(
        title: const Text('Personal CFO • Lab'),
        backgroundColor: StackMoneyTheme.background,
        centerTitle: false,
      ),
      body: Column(
        children: [
          /// Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.x4,
                vertical: AppSizes.x4,
              ),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isUser = msg.sender == MessageSender.user;

                if (isUser) {
                  return UserMessage(msg: msg);
                }

                return AiMessage(msg: msg, handleActionResponse: _handleActionResponse);
              },
            ),
          ),

          /// Send Message
          SendMessage(controller: _textController, onSend: _sendMessage),
        ],
      ),
    );
  }
}
