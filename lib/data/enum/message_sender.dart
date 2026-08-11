enum MessageSender {
  user,
  cfoAi;

  static MessageSender fromJson(String? json) {
    return MessageSender.values.firstWhere(
      (e) => e.name == json,
      orElse: () => MessageSender.user,
    );
  }
}
