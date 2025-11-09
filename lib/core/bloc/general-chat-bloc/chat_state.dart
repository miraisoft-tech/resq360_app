part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

/// Initial / Idle
class ChatInitial extends ChatState {}

/// 🔌 Socket Connection
class ConnectingSocketState extends ChatState {}
class ChatSocketConnected extends ChatState {}

/// 💬 Chat Creation / Loading
class CreatingChatState extends ChatState {}
class ChatLoadedState extends ChatState {
  const ChatLoadedState(this.chat);
  final ChatResponse chat;
  @override
  List<Object?> get props => [chat];
}

/// 📜 Chat List Loading
class FetchingChatsState extends ChatState {}
class ChatListLoadedState extends ChatState {
  const ChatListLoadedState(this.chats);
  final ChatListResponse chats;
  @override
  List<Object?> get props => [chats];
}

/// 📨 Message Loading
class FetchingMessagesState extends ChatState {}
class MessagesLoaded extends ChatState {
  const MessagesLoaded(this.messages);
  final ChatMessagesResponse messages;
  @override
  List<Object?> get props => [messages];
}

/// 📩 Message Sending
class MessageSent extends ChatState {
  const MessageSent();
}

/// 🔔 New Message Received
class NewMessageState extends ChatState {
  const NewMessageState(this.message);
  final MessageResponse message;
  @override
  List<Object?> get props => [message];
}

/// 👁️ Message Read
class MessageRead extends ChatState {
  const MessageRead(this.messageId);
  final int messageId;
  @override
  List<Object?> get props => [messageId];
}

/// 🚪 Leaving Chat
class LeavingChatState extends ChatState {}
class ChatLeft extends ChatState {}

/// ❌ Error State
class ChatErrorState extends ChatState {
  const ChatErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
