part of 'customer_chat_bloc.dart';


sealed class CustomerChatState extends Equatable {
  const CustomerChatState();
  
  @override
  List<Object?> get props => [];
}

final class CustomerChatInitial extends CustomerChatState {}
class CustomerChatLoadingState extends CustomerChatState {}

class CustomerChatErrorState extends CustomerChatState {
  const CustomerChatErrorState(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class CustomerChatLoadedState extends CustomerChatState {
  const CustomerChatLoadedState(this.chat);
  final ChatResponse chat;

  @override
  List<Object?> get props => [chat];
}

class CustomerChatListLoadedState extends CustomerChatState {
  const CustomerChatListLoadedState(this.chats);
  final List<ChatResponse> chats;

  @override
  List<Object?> get props => [chats];
}

class MessagesLoaded extends CustomerChatState {
  const MessagesLoaded(this.messages);
  final ChatMessagesResponse messages;

  @override
  List<Object?> get props => [messages];
}

// class CustomerMessagesErrorState extends CustomerChatState {
//   const CustomerMessagesErrorState(this.message);
//   final String message;

//   @override
//   List<Object?> get props => [message];
// }




class MessageSent extends CustomerChatState {
  const MessageSent(this.message);
  final MessageResponse message;
  
  @override
  List<Object?> get props => [message];
}

class MessageRead extends CustomerChatState {
  const MessageRead(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class ChatLeft extends CustomerChatState {}
