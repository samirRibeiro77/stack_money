import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/data/enum/message_sender.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:stack_money/data/models/proposed_action_model.dart';
import 'package:uuid/uuid.dart';

class ChatMessageModel {
  final String _id;
  final MessageSender sender;
  final String text;
  final Timestamp timestamp;
  final ProposedActionModel? proposedAction;

  String get id => _id;

  ChatMessageModel({
    String? id,
    required this.sender,
    required this.text,
    Timestamp? timestamp,
    this.proposedAction,
  }) : _id = id ?? const Uuid().v4(),
       timestamp = timestamp ?? Timestamp.now();

  factory ChatMessageModel.fromJson(Map<String, Object?>? json, {String? id}) {
    return ChatMessageModel(
      id: id ?? json?[ModelKey.id] as String?,
      sender: MessageSender.fromJson(json?[ModelKey.sender] as String?),
      text: json?[ModelKey.text] as String? ?? '',
      timestamp: json?[ModelKey.date] as Timestamp? ?? Timestamp.now(),
      proposedAction: ProposedActionModel.fromJson(
        json?[ModelKey.proposedAction] as Map<String, Object?>?,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ModelKey.id: _id,
      ModelKey.sender: sender.name,
      ModelKey.text: text,
      ModelKey.date: timestamp,
      ModelKey.proposedAction: proposedAction?.toJson(),
    };
  }

  ChatMessageModel copyWith({
    String? text,
    ProposedActionModel? proposedAction,
    bool newId = false,
  }) {
    return ChatMessageModel(
      id: newId ? const Uuid().v4() : _id,
      sender: sender,
      text: text ?? this.text,
      timestamp: timestamp,
      proposedAction: proposedAction ?? this.proposedAction,
    );
  }
}
