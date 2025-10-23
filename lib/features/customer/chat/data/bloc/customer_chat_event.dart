
part of 'customer_chat_bloc.dart';

sealed class CustomerChatEvent extends Equatable {
  const CustomerChatEvent();

  @override
  List<Object?> get props => [];
}

class CreateChatEvent extends CustomerChatEvent {
  const CreateChatEvent(this.chatRequest);
  final CreateChatRequest chatRequest;

  @override
  List<Object?> get props => [chatRequest];
}

class GetChatsEvent extends CustomerChatEvent {}

class SendMessageEvent extends CustomerChatEvent {
  const SendMessageEvent({required this.messageRequest});
  final SendMessageRequest messageRequest;

  @override
  List<Object?> get props => [messageRequest];
}

class GetChatMessagesEvent extends CustomerChatEvent {
  const GetChatMessagesEvent({required this.chatId});
  final String chatId;

  @override
  List<Object?> get props => [chatId];
}

class MarkMessageAsReadEvent extends CustomerChatEvent {
  const MarkMessageAsReadEvent(this.messageId);
  final String messageId;

  @override
  List<Object?> get props => [messageId];
}

class LeaveChatEvent extends CustomerChatEvent {
  const LeaveChatEvent(this.chatId);
  final String chatId;

  @override
  List<Object?> get props => [chatId];
}

