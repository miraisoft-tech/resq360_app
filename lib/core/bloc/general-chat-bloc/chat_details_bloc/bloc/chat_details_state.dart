part of 'chat_details_bloc.dart';

sealed class ChatDetailsState extends Equatable {
  const ChatDetailsState();
  
  @override
  List<Object> get props => [];
}

final class ChatDetailsInitial extends ChatDetailsState {}

sealed class ChatDetailState extends Equatable {
  const ChatDetailState();

  @override
  List<Object?> get props => [];
}

class ChatDetailInitial extends ChatDetailState {}

class ChatDetailLoading extends ChatDetailState {}

class ChatDetailReady extends ChatDetailState {

  const ChatDetailReady({
    required this.chatId,
    required this.title,
    required this.messages,
  });
  final int chatId;
  final String title;
  final List<MessageResponse> messages;

  ChatDetailReady copyWith({
    List<MessageResponse>? messages,
  }) {
    return ChatDetailReady(
      chatId: chatId,
      title: title,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [chatId, title, messages];
}


class ChatDetailFailure extends ChatDetailState {
  const ChatDetailFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
