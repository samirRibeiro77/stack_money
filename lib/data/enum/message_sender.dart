enum MessageSender {
  user,
  cfoAi;

  bool get isUser => this == user;

  static MessageSender fromJson(String? json) {
    return MessageSender.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageSender.user,
    );
  }
}
