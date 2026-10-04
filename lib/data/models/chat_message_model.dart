import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/core/helpers/timestamp_parser.dart';
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
  final bool failedSend;

  String get id => _id;

  ChatMessageModel({
    String? id,
    required this.sender,
    required this.text,
    Timestamp? timestamp,
    this.proposedAction,
    this.failedSend = false,
  }) : _id = id ?? const Uuid().v4(),
       timestamp = TimestampParser.fromJson(timestamp);

  factory ChatMessageModel.fromJson(Map<String, Object?>? json, {String? id}) {
    return ChatMessageModel(
      id: id ?? json?[ModelKey.id] as String?,
      sender: MessageSender.fromJson(json?[ModelKey.sender] as String?),
      text: json?[ModelKey.text] as String? ?? '',
      timestamp: TimestampParser.fromJson(json?[ModelKey.date]),
      proposedAction: ProposedActionModel.fromJson(
        json?[ModelKey.proposedAction] as Map<String, Object?>?,
      ),
      failedSend: json?[ModelKey.failedSend] as bool? ?? false,
    );
  }

  Map<String, Object?> toJson() {
    return {
      ModelKey.id: _id,
      ModelKey.sender: sender.name,
      ModelKey.text: text,
      ModelKey.date: timestamp,
      ModelKey.proposedAction: proposedAction?.toJson(),
      ModelKey.failedSend: failedSend,
    };
  }

  ChatMessageModel copyWith({
    String? text,
    ProposedActionModel? proposedAction,
    bool? failedSend,
    bool newId = false,
  }) {
    return ChatMessageModel(
      id: newId ? const Uuid().v4() : _id,
      sender: sender,
      text: text ?? this.text,
      timestamp: timestamp,
      proposedAction: proposedAction ?? this.proposedAction,
      failedSend: failedSend ?? this.failedSend,
    );
  }
}
