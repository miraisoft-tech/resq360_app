class ChatSummary {

  ChatSummary({
    required this.chatId,
    required this.title,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });
  final int chatId;
  final String title;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;

  ChatSummary copyWith({
    String? lastMessage,
    DateTime? lastMessageTime,
    int? unreadCount,
  }) {
    return ChatSummary(
      chatId: chatId,
      title: title,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}
