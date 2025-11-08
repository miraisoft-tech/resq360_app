part of 'customer_chat_bloc.dart';

abstract class CustomerChatState extends Equatable {
  const CustomerChatState();

  @override
  List<Object?> get props => [];
}

/// Initial / Idle
class CustomerChatInitial extends CustomerChatState {}

/// 🔌 Socket Connection
class ConnectingSocketState extends CustomerChatState {}
class CustomerChatSocketConnected extends CustomerChatState {}

/// 💬 Chat Creation / Loading
class CreatingChatState extends CustomerChatState {}
class CustomerChatLoadedState extends CustomerChatState {
  const CustomerChatLoadedState(this.chat);
  final ChatResponse chat;
  @override
  List<Object?> get props => [chat];
}

/// 📜 Chat List Loading
class FetchingChatsState extends CustomerChatState {}
class CustomerChatListLoadedState extends CustomerChatState {
  const CustomerChatListLoadedState(this.chats);
  final ChatListResponse chats;
  @override
  List<Object?> get props => [chats];
}

/// 📨 Message Loading
class FetchingMessagesState extends CustomerChatState {}
class MessagesLoaded extends CustomerChatState {
  const MessagesLoaded(this.messages);
  final ChatMessagesResponse messages;
  @override
  List<Object?> get props => [messages];
}

/// 📩 Message Sending
class MessageSent extends CustomerChatState {
  const MessageSent();
}

/// 🔔 New Message Received
class NewMessageState extends CustomerChatState {
  const NewMessageState(this.message);
  final MessageResponse message;
  @override
  List<Object?> get props => [message];
}

/// 👁️ Message Read
class MessageRead extends CustomerChatState {
  const MessageRead(this.messageId);
  final int messageId;
  @override
  List<Object?> get props => [messageId];
}

/// 🚪 Leaving Chat
class LeavingChatState extends CustomerChatState {}
class ChatLeft extends CustomerChatState {}

/// ❌ Error State
class CustomerChatErrorState extends CustomerChatState {
  const CustomerChatErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}
