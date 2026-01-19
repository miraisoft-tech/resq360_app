import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/models/chat_summary.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({ChatRepo? chatRepo})
    : _repo = chatRepo ?? ChatRepo(),
      super(const ChatListState()) {
    on<LoadChatList>(_onLoadChats);
    on<RefreshChatList>(_onRefreshChats);
    on<ChatSummaryUpdated>(_onChatUpdated);
    on<ClearUnreadCount>(_onClearUnread);
  }

  final ChatRepo _repo;

  Future<void> _onLoadChats(
    LoadChatList event,
    Emitter<ChatListState> emit,
  ) async {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
      ),
    );

    final result = await _repo.getChats(
      pageNumber: state.page,
      limit: 20,
    );

    if (result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error ?? 'Failed to load chats',
        ),
      );
      return;
    }

    final response = result.data!;
    final newChats = response.chats.map(_mapToSummary).toList();

    final isFirstPage = state.page == 1;

    emit(
      state.copyWith(
        isLoading: false,
        chats: isFirstPage ? newChats : [...state.chats, ...newChats],
        page: response.page,
        totalPages: response.totalPages,
      ),
    );
  }

  Future<void> _onRefreshChats(
    RefreshChatList event,
    Emitter<ChatListState> emit,
  ) async {
    emit(const ChatListState(isLoading: true));

    final result = await _repo.getChats(pageNumber: 1);

    if (result.data == null) {
      emit(
        state.copyWith(
          isLoading: false,
          error: result.error,
        ),
      );
      return;
    }

    final response = result.data!;

    emit(
      ChatListState(
        chats: response.chats.map(_mapToSummary).toList(),
        page: response.page,
        totalPages: response.totalPages,
      ),
    );
  }

  void _onChatUpdated(
    ChatSummaryUpdated event,
    Emitter<ChatListState> emit,
  ) {
    final chats = [...state.chats];

    final index = chats.indexWhere((c) => c.chatId == event.chatId);
    if (index == -1) return;

    final chat = chats.removeAt(index);

    chats.insert(
      0,
      chat.copyWith(
        lastMessage: event.lastMessage,
        lastMessageTime: event.time,
        unreadCount: event.isFromCurrentChat ? 0 : chat.unreadCount + 1,
      ),
    );

    emit(state.copyWith(chats: chats));
  }

  void _onClearUnread(
    ClearUnreadCount event,
    Emitter<ChatListState> emit,
  ) {
    emit(
      state.copyWith(
        chats:
            state.chats.map((chat) {
              if (chat.chatId == event.chatId) {
                return chat.copyWith(unreadCount: 0);
              }
              return chat;
            }).toList(),
      ),
    );
  }

  ChatSummary _mapToSummary(ChatResponse chat) {
    return ChatSummary(
      chatId: chat.id!,
      title: chat.title!,
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageAt,
      imgurl: chat.image ?? '',
    );
  }
}
