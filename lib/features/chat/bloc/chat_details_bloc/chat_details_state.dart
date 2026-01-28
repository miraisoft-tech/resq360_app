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
    this.currentPage = 1,
    this.totalPages = 1,
    this.isLoadingMore = false,
    this.hasMoreMessages = false,
  });

  final ChatResponse chat;
  final List<MessageResponse> messages;
  final int currentPage;
  final int totalPages;
  final bool isLoadingMore;
  final bool hasMoreMessages;

  ChatDetailReady copyWith({
    ChatResponse? chat,
    List<MessageResponse>? messages,
    int? currentPage,
    int? totalPages,
    bool? isLoadingMore,
    bool? hasMoreMessages,
  }) {
    return ChatDetailReady(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
    );
  }

  @override
  List<Object?> get props => [
    chat,
    messages,
    currentPage,
    totalPages,
    isLoadingMore,
    hasMoreMessages,
  ];
}

class ChatDetailFailure extends ChatDetailState {
  const ChatDetailFailure(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}


/// State emitted when report is successful
final class ChatDetailReportSuccess extends ChatDetailState {
  const ChatDetailReportSuccess();
}

final class ChatDetailActionFailure extends ChatDetailState {
  const ChatDetailActionFailure({required this.error});

  final String error;

  @override
  List<Object?> get props => [
    error,
  ];
}
