import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:stack_money/data/helper/model_key.dart';
import 'package:uuid/uuid.dart';

class ChatThreadModel {
  final String _id;
  final String title;
  final Timestamp createdAt;
  final Timestamp updatedAt;
  final bool isArchived;
  final String lastMessage;

  String get id => _id;

  ChatThreadModel({
    String? id,
    required this.title,
    Timestamp? createdAt,
    Timestamp? updatedAt,
    this.isArchived = false,
    required this.lastMessage,
  }) : _id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? Timestamp.now(),
       updatedAt = updatedAt ?? Timestamp.now();

  factory ChatThreadModel.fromJson(Map<String, Object?>? json, {String? id}) {
    return ChatThreadModel(
      id: id ?? json?[ModelKey.id] as String?,
      title: json?[ModelKey.title] as String? ?? '',
      createdAt: json?[ModelKey.createdAt] as Timestamp? ?? Timestamp.now(),
      updatedAt: json?[ModelKey.updateAt] as Timestamp? ?? Timestamp.now(),
      isArchived: json?[ModelKey.isArchived] as bool? ?? false,
      lastMessage: json?[ModelKey.lastMessage] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      ModelKey.id: _id,
      ModelKey.title: title,
      ModelKey.createdAt: createdAt,
      ModelKey.updateAt: updatedAt,
      ModelKey.isArchived: isArchived,
      ModelKey.lastMessage: lastMessage,
    };
  }

  ChatThreadModel copyWith({
    String? title,
    Timestamp? updatedAt,
    bool? isArchived,
    String? lastMessage,
    bool newId = false,
  }) {
    return ChatThreadModel(
      id: newId ? const Uuid().v4() : _id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}
