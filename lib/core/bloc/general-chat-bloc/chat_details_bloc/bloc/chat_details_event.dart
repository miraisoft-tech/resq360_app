part of 'chat_details_bloc.dart';

sealed class ChatDetailsEvent extends Equatable {
  const ChatDetailsEvent();

  @override
  List<Object> get props => [];
}
sealed class ChatDetailEvent extends Equatable {
  const ChatDetailEvent();

  @override
  List<Object?> get props => [];
}

class OpenChatDetail extends ChatDetailEvent {
  const OpenChatDetail(this.chatId);
  final int chatId;

  @override
  List<Object?> get props => [chatId];
}

class SendTextMessage extends ChatDetailEvent {
  const SendTextMessage(this.content);
  final String content;

  @override
  List<Object?> get props => [content];
}

class RefreshMessages extends ChatDetailEvent {}

/// INTERNAL (socket only)
class _IncomingMessage extends ChatDetailEvent {
  const _IncomingMessage(this.message);
  final MessageResponse message;
}
