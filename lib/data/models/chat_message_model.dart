import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';

class ChatMessageModel {
  final String id;
  final String chatId;
  final MessageSender sender;
  final String text;
  final DateTime timestamp;
  final ProposedActionModel? proposedAction;

  const ChatMessageModel({
    required this.id,
    required this.chatId,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.proposedAction,
  });

  ChatMessageModel copyWith({
    ProposedActionModel? proposedAction,
  }) {
    return ChatMessageModel(
      id: id,
      chatId: chatId,
      sender: sender,
      text: text,
      timestamp: timestamp,
      proposedAction: proposedAction ?? this.proposedAction,
    );
  }
}