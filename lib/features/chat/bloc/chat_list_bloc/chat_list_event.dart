part of 'chat_list_bloc.dart';

sealed class ChatListEvent extends Equatable {
  const ChatListEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatList extends ChatListEvent {}

class RefreshChatList extends ChatListEvent {}

class ChatSummaryUpdated extends ChatListEvent {

  const ChatSummaryUpdated({
    required this.chatId,
    required this.lastMessage,
    required this.time,
    this.isFromCurrentChat = false,
  });
  final int chatId;
  final String lastMessage;
  final DateTime time;
  final bool isFromCurrentChat;

  @override
  List<Object?> get props => [chatId, lastMessage, time, isFromCurrentChat];
}

class ClearUnreadCount extends ChatListEvent {
  const ClearUnreadCount(this.chatId);
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}
