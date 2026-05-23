import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/models/chat_summary.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/chat/data/models/chat_models.dart';
import 'package:resq360/features/chat/data/services/chat_repo.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/settings/data/models/ticket_message.model.dart';

part 'chat_list_event.dart';
part 'chat_list_state.dart';

class ChatListBloc extends Bloc<ChatListEvent, ChatListState> {
  ChatListBloc({ChatRepo? chatRepo, this.userType})
    : _repo = chatRepo ?? ChatRepo(),
      super(const ChatListState()) {
    on<LoadChatList>(_onLoadChats);
    on<RefreshChatList>(_onRefreshChats);
    on<ChatSummaryUpdated>(_onChatUpdated);
    on<ClearUnreadCount>(_onClearUnread);
  }

  final ChatRepo _repo;
  final UserType? userType;
  int? _currentUserId;
  String? _participantType;

  Future<void> _ensureUserId() async {
    if (_currentUserId != null) return;
    if (userType == UserType.provider) {
      _currentUserId = await AuthLocalRepo.instance.getProviderId();
      _participantType = 'PROVIDER';
    } else if (userType == UserType.customer) {
      _currentUserId = await AuthLocalRepo.instance.getCustomerId();
      _participantType = 'USER';
    } else {
      // Try provider first, fallback to customer
      final providerId = await AuthLocalRepo.instance.getProviderId();
      if (providerId != null) {
        _currentUserId = providerId;
        _participantType = 'PROVIDER';
      } else {
        _currentUserId = await AuthLocalRepo.instance.getCustomerId();
        _participantType = 'USER';
      }
    }
  }

  Future<void> _onLoadChats(
    LoadChatList event,
    Emitter<ChatListState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true));

    await _ensureUserId();

    final result = await _repo.getChats(pageNumber: state.page, limit: 20);

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

    await _ensureUserId();

    final result = await _repo.getChats(pageNumber: 1);

    if (result.data == null) {
      emit(state.copyWith(isLoading: false, error: result.error));
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

  void _onChatUpdated(ChatSummaryUpdated event, Emitter<ChatListState> emit) {
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

  void _onClearUnread(ClearUnreadCount event, Emitter<ChatListState> emit) {
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
    // Determine unread from the single message in the messages list
    var unread = 0;
    if (chat.messages != null && chat.messages!.isNotEmpty) {
      final lastMsg = chat.messages!.first;
      final isFromOther =
          lastMsg.senderType != _participantType ||
          lastMsg.senderId != _currentUserId;
      if (isFromOther && lastMsg.status != MessageStatus.read) {
        unread = 1;
      }
    }

    return ChatSummary(
      chatId: chat.id!,
      title: chat.title!,
      lastMessage: chat.lastMessage,
      lastMessageTime: chat.lastMessageAt,
      imgurl: chat.image ?? '',
      unreadCount: unread,
    );
  }
}
