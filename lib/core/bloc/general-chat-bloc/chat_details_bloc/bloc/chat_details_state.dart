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
    required this.chat,
    required this.messages,
  });

  final ChatResponse chat;                
  final List<MessageResponse> messages;    

  ChatDetailReady copyWith({
    ChatResponse? chat,
    List<MessageResponse>? messages,
  }) {
    return ChatDetailReady(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
    );
  }

  @override
  List<Object?> get props => [chat, messages];
}



class ChatDetailFailure extends ChatDetailState {
  const ChatDetailFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
