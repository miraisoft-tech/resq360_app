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

class SendFileMessageEvent extends CustomerChatEvent {
  const SendFileMessageEvent({
    required this.chatId,
    required this.file,
    required this.fileName,
    required this.mimeType,
  });

  final int chatId;
  final File file;
  final String fileName;
  final String mimeType;

  @override
  List<Object?> get props => [chatId, file, fileName, mimeType];
}

class GetChatMessagesEvent extends CustomerChatEvent {
  const GetChatMessagesEvent({required this.chatId});
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}

class MarkMessageAsReadEvent extends CustomerChatEvent {
  const MarkMessageAsReadEvent(this.messageId);
  final int messageId;

  @override
  List<Object?> get props => [messageId];
}

class LeaveChatEvent extends CustomerChatEvent {
  const LeaveChatEvent(this.chatId);
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}

class LoadMoreMessagesEvent extends CustomerChatEvent {
  const LoadMoreMessagesEvent({required this.chatId, required this.lastMessageId});
  final int chatId;
  final int lastMessageId;

  @override
  List<Object?> get props => [chatId, lastMessageId];
}

