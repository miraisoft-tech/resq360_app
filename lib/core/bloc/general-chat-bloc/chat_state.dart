part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}


class ChatInitial extends ChatState {}

/// Socket Connection
class ConnectingSocketState extends ChatState {}
class ChatSocketConnected extends ChatState {}

class CreatingChatState extends ChatState {}
class ChatLoadedState extends ChatState {
  const ChatLoadedState(this.chat);
  final ChatResponse chat;
  @override
  List<Object?> get props => [chat];
}

class FetchingChatsState extends ChatState {}
class ChatListLoadedState extends ChatState {
  const ChatListLoadedState(this.chats);
  final ChatListResponse chats;
  @override
  List<Object?> get props => [chats];
}


class FetchingMessagesState extends ChatState {}
class MessagesLoaded extends ChatState {
  const MessagesLoaded(this.messages);
  final ChatMessagesResponse messages;
  @override
  List<Object?> get props => [messages];
}


class MessageSent extends ChatState {
  const MessageSent(this.message);
  final MessageResponse message;
  @override
  List<Object?> get props => [message];
}


class NewMessageState extends ChatState {
  const NewMessageState(this.message);
  final MessageResponse message;
  @override
  List<Object?> get props => [message];
}


class MessageRead extends ChatState {
  const MessageRead(this.messageId);
  final int messageId;
  @override
  List<Object?> get props => [messageId];
}

class ChatJoinedState extends ChatState {
  const ChatJoinedState(this.chatId);
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}


class LeavingChatState extends ChatState {}
class ChatLeft extends ChatState {}

/// Error State
class ChatErrorState extends ChatState {
  const ChatErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
