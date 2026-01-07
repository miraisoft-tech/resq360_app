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
  const SendTextMessage(this.content, this.senderid, this.userType);
  final String content;
  final int senderid;
  final String userType;

  @override
  List<Object?> get props => [content];
}
class SendInvoiceMessage extends ChatDetailEvent {
  const SendInvoiceMessage(this.invoice);

  final SendInvoice invoice;

  @override
  List<Object?> get props => [invoice];
}

class RefreshMessages extends ChatDetailEvent {}

class _IncomingMessage extends ChatDetailEvent {
  const _IncomingMessage(this.message);
  final MessageResponse message;
}
