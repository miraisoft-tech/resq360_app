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

class SendImageMessage extends ChatDetailEvent {
  const SendImageMessage({
    required this.filePaths,
    required this.senderId,
    required this.userType,
    this.caption,
  });

  final List<String> filePaths;
  final int senderId;
  final String userType;
  final String? caption;

  @override
  List<Object?> get props => [filePaths, senderId, userType, caption];
}
class SendDocumentMessage extends ChatDetailEvent {
  const SendDocumentMessage({
    required this.filePath,
    required this.senderId,
    required this.userType,
  });

  final String filePath;
  final int senderId;
  final String userType;

  @override
  List<Object?> get props => [filePath, senderId, userType];
}

class SendLocationMessage extends ChatDetailEvent {
  const SendLocationMessage({
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.senderId,
    required this.userType,
  });

  final double latitude;
  final double longitude;
  final String address;
  final int senderId;
  final String userType;

  @override
  List<Object?> get props => [latitude, longitude, address, senderId, userType];
}

class RefreshMessages extends ChatDetailEvent {}

class LoadMoreMessages extends ChatDetailEvent {}

class _IncomingMessage extends ChatDetailEvent {
  const _IncomingMessage(this.message);
  final MessageResponse message;
}



/// Event to report a chat with a specific reason
final class ReportChat extends ChatDetailEvent {
  const ReportChat({
    required this.chatId,
    required this.reason,
  });

  final int chatId;
  final String reason;

  @override
  List<Object?> get props => [chatId, reason];
}
final class BlockUser extends ChatDetailEvent {
  const BlockUser({
    required this.userId,
    required this.userType,
    required this.chatId,
  });

  final int userId;
  final String userType; // 'PROVIDER' or 'USER'
  final int chatId;

  @override
  List<Object?> get props => [userId, userType, chatId];
}

/// Event to unblock a user
final class UnblockUser extends ChatDetailEvent {
  const UnblockUser({
    required this.userId,
    required this.userType,
  });

  final int userId;
  final String userType;

  @override
  List<Object?> get props => [userId, userType];
}
