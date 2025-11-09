part of 'chat_bloc.dart';


sealed class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class ConnectChatSocketEvent extends ChatEvent {}
class NewMessageReceivedEvent extends ChatEvent {
  const NewMessageReceivedEvent(this.message);
  final MessageResponse message;
}

class CreateChatEvent extends ChatEvent {
  const CreateChatEvent({ required this.chatRequest});
  final CreateChatRequest chatRequest;

  @override
  List<Object?> get props => [chatRequest];
}

class GetChatsEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  const SendMessageEvent({required this.messageRequest});
  final SendMessageRequest messageRequest;

  @override
  List<Object?> get props => [messageRequest];
}

class SendFileMessageEvent extends ChatEvent {
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

class GetChatMessagesEvent extends ChatEvent {
  const GetChatMessagesEvent({required this.chatId});
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}

class MarkMessageAsReadEvent extends ChatEvent {
  const MarkMessageAsReadEvent(this.messageId);
  final int messageId;

  @override
  List<Object?> get props => [messageId];
}

class LeaveChatEvent extends ChatEvent {
  const LeaveChatEvent(this.chatId);
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}

class LoadMoreMessagesEvent extends ChatEvent {
  const LoadMoreMessagesEvent({required this.chatId, required this.lastMessageId});
  final int chatId;
  final int lastMessageId;

  @override
  List<Object?> get props => [chatId, lastMessageId];
}
