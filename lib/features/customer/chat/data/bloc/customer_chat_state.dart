part of 'customer_chat_bloc.dart';

sealed class CustomerChatState extends Equatable {
  const CustomerChatState();

  @override
  List<Object?> get props => [];
}

final class CustomerChatInitial extends CustomerChatState {}

/// Global loading state (used for fetching chats or messages)
class CustomerChatLoadingState extends CustomerChatState {}

/// Global error state
class CustomerChatErrorState extends CustomerChatState {
  const CustomerChatErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

/// State when a single chat is loaded (e.g., after creating a new chat)
class CustomerChatLoadedState extends CustomerChatState {
  const CustomerChatLoadedState(this.chat);
  final ChatResponse chat;

  @override
  List<Object?> get props => [chat];
}

/// State when multiple chats are loaded
class CustomerChatListLoadedState extends CustomerChatState {
  const CustomerChatListLoadedState(this.chats);
  final ChatListResponse chats;

  @override
  List<Object?> get props => [chats];
}

/// State when messages of a chat are loaded
class MessagesLoaded extends CustomerChatState {
  const MessagesLoaded(this.messages);
  final ChatMessagesResponse messages;

  @override
  List<Object?> get props => [messages];
}

/// State when message sending is in progress
class MessageSending extends CustomerChatState {}

/// State when a message is successfully sent
class MessageSent extends CustomerChatState {
  const MessageSent(this.message);
  final MessageResponse message;

  @override
  List<Object?> get props => [message];
}

/// State when a message is marked as read
class MessageRead extends CustomerChatState {
  const MessageRead(this.messageId);
  final int messageId;

  @override
  List<Object?> get props => [messageId];
}

/// State when user has left a chat
class ChatLeft extends CustomerChatState {}
