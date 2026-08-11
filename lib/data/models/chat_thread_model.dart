class ChatThreadModel {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final String lastMessage;

  const ChatThreadModel({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.isArchived = false,

    required this.lastMessage,
  });

  ChatThreadModel copyWith({
    String? title,
    DateTime? updatedAt,
    bool? isArchived,
    String? lastMessage,
  }) {
    return ChatThreadModel(
      id: id,
      title: title ?? this.title,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isArchived: isArchived ?? this.isArchived,
      lastMessage: lastMessage ?? this.lastMessage,
    );
  }
}