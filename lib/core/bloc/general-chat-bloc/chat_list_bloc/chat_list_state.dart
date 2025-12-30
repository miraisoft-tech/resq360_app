part of 'chat_list_bloc.dart';

// sealed class ChatListState extends Equatable {
//   const ChatListState();
  
//   @override
//   List<Object> get props => [];
// }

class ChatListState extends Equatable {

  const ChatListState({
    this.isLoading = false,
    this.chats = const [],
    this.page = 1,
    this.totalPages = 1,
    this.error,
  });
  final bool isLoading;
  final List<ChatSummary> chats;
  final int page;
  final int totalPages;
  final String? error;

  bool get canLoadMore => page < totalPages;

  ChatListState copyWith({
    bool? isLoading,
    List<ChatSummary>? chats,
    int? page,
    int? totalPages,
    String? error,
  }) {
    return ChatListState(
      isLoading: isLoading ?? this.isLoading,
      chats: chats ?? this.chats,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        chats,
        page,
        totalPages,
        error,
      ];
}
