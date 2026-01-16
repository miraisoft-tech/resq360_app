import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/chat_cache_service.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/metadata.dart';
import 'package:resq360/features/customer/chat/data/models/chat/send_invoice_request.dart';
import 'package:resq360/features/customer/chat/data/models/chat/send_message_request.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';

part 'chat_details_event.dart';
part 'chat_details_state.dart';

class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  ChatDetailBloc({
    required this.chatId,
    ChatRepo? chatRepo,
    ChatSocketService? socket,
    ChatCacheService? cache,
  }) : _repo = chatRepo ?? ChatRepo(),
       _socket = socket ?? ChatSocketService.instance,
       _cache = cache ?? ChatCacheService.instance,
       super(ChatDetailInitial()) {
    on<OpenChatDetail>(_onOpenChatDetail);
    on<SendTextMessage>(_onSendMessage);
    on<SendInvoiceMessage>(_onSendInvoiceMessage);
    on<RefreshMessages>(_onRefreshMessages);
    on<LoadMoreMessages>(_onLoadMoreMessages);
    on<_IncomingMessage>(_onIncomingMessage);
  }

  final int chatId;
  final ChatRepo _repo;
  final ChatSocketService _socket;
  final ChatCacheService _cache;
  StreamSubscription<dynamic>? _socketSub;

  Future<void> _onOpenChatDetail(
    OpenChatDetail event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      // Check cache first - show cached data immediately if available
      final cachedData = _cache.getCachedData(event.chatId);
      if (cachedData != null) {
        // Emit cached data immediately (no loading state)
        emit(
          ChatDetailReady(
            chat: cachedData.chat,
            messages: cachedData.messages,
            currentPage: cachedData.currentPage,
            totalPages: cachedData.totalPages,
            hasMoreMessages: cachedData.hasMoreMessages,
          ),
        );

        // Connect socket
        await _connectSocket();

        await _refreshInBackground(event.chatId, emit);
        return;
      }

      // No cache - show loading and fetch fresh data
      emit(ChatDetailLoading());

      final chatResult = await _repo.getChatById(event.chatId);

      if (chatResult.data == null) {
        emit(ChatDetailFailure(chatResult.error ?? 'Failed to load chat'));
        return;
      }

      final messagesResult = await _repo.getChatMessages(event.chatId);

      if (messagesResult.data == null) {
        emit(
          ChatDetailFailure(messagesResult.error ?? 'Failed to load messages'),
        );
        return;
      }

      await _connectSocket();

      final chat = chatResult.data!;
      final messagesData = messagesResult.data!;

      // Cache the data
      _cache.cacheData(
        chatId: event.chatId,
        chat: chat,
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      );

      emit(
        ChatDetailReady(
          chat: chat,
          messages: messagesData.messages,
          currentPage: messagesData.page,
          totalPages: messagesData.totalPages,
          hasMoreMessages: messagesData.page < messagesData.totalPages,
        ),
      );
    } on Exception catch (e) {
      emit(ChatDetailFailure(e.toString()));
    }
  }

  /// Refresh data in background without showing loading state
  Future<void> _refreshInBackground(
    int chatId,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
      final chatResult = await _repo.getChatById(chatId);
      final messagesResult = await _repo.getChatMessages(chatId);

      if (chatResult.data == null || messagesResult.data == null) return;

      final chat = chatResult.data!;
      final messagesData = messagesResult.data!;

      // Update cache
      _cache.cacheData(
        chatId: chatId,
        chat: chat,
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      );

      // Only update if still in ready state and messages have changed
      if (state is ChatDetailReady) {
        final current = state as ChatDetailReady;
        // Check if there are newer messages
        if (messagesData.messages.isNotEmpty &&
            current.messages.isNotEmpty &&
            messagesData.messages.first.id != current.messages.first.id) {
          emit(
            current.copyWith(
              chat: chat,
              messages: messagesData.messages,
              currentPage: messagesData.page,
              totalPages: messagesData.totalPages,
              hasMoreMessages: messagesData.page < messagesData.totalPages,
            ),
          );
        }
      }
    } on Exception catch (e) {
      log('Background refresh failed: $e');
    }
  }

  Future<void> _connectSocket() async {
    try {
      await _socket.connect();

      unawaited(_socket.joinChat(chatId));

      await _socketSub?.cancel();
      _socketSub = _socket.messageStream.listen(
        (msg) {
          if ((msg.chatId == chatId) &&
              !(msg.senderType?.contains('USER') ?? false)) {
            add(_IncomingMessage(msg));
          }
        },
      );
    } on Exception catch (e) {
      log('Socket connection error: $e');
    }
  }

  Future<void> _onSendInvoiceMessage(
    SendInvoiceMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    final current = state;
    if (current is! ChatDetailReady) return;

    final localMessage = MessageResponse(
      id: DateTime.now().millisecondsSinceEpoch * -1,
      chatId: current.chat.id,
      senderType: 'PROVIDER',
      messageType: 'SYSTEM',
      content: event.invoice.description ?? 'Invoice',
      createdAt: DateTime.now(),
      metadata: Metadata(
        type: 'INVOICE',
        amount: event.invoice.amount,
        currency: event.invoice.currency,
        invoiceId: event.invoice.invoiceId,
        description: event.invoice.description,
      ),
    );

    final newMessages = [localMessage, ...current.messages];

    // Update cache
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(
      current.copyWith(
        messages: newMessages,
      ),
    );

    final result = await _repo.sendInvoice(
      invoiceRequest: event.invoice,
    );

    if (result.data == null) {
      emit(
        current.copyWith(
          messages: current.messages,
        ),
      );
      return;
    }

    final confirmedMessages = [
      result.data!,
      ...current.messages.where((m) => m.id != localMessage.id),
    ];

    // Update cache with confirmed message
    _cache.updateMessages(chatId: chatId, messages: confirmedMessages);

    emit(
      current.copyWith(
        messages: confirmedMessages,
      ),
    );
  }

  Future<void> _onSendMessage(
    SendTextMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final localMessage = MessageResponse(
      id: DateTime.now().millisecondsSinceEpoch * -1,
      chatId: chatId,
      senderType: event.userType,
      senderId: event.senderid,
      messageType: 'TEXT',
      content: event.content,
      createdAt: DateTime.now(),
    );

    final newMessages = [localMessage, ...current.messages];

    // Update cache
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(
      current.copyWith(
        messages: newMessages,
      ),
    );

    _socket.sendMessage(
      SendMessageRequest(
        chatId: chatId,
        messageType: 'TEXT',
        content: event.content,
      ),
    );
  }

  void _onIncomingMessage(
    _IncomingMessage event,
    Emitter<ChatDetailState> emit,
  ) {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final confirmedMessages =
        current.messages.where((m) => m.id == null || m.id! > 0).toList();

    final newMessages = [event.message, ...confirmedMessages];

    // Update cache with new messages
    _cache.updateMessages(chatId: chatId, messages: newMessages);

    emit(
      current.copyWith(
        messages: newMessages,
      ),
    );
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    final result = await _repo.getChatMessages(chatId);
    if (result.data == null) return;

    final messagesData = result.data!;

    // Update cache
    _cache.updateMessages(
      chatId: chatId,
      messages: messagesData.messages,
      currentPage: messagesData.page,
      totalPages: messagesData.totalPages,
      hasMoreMessages: messagesData.page < messagesData.totalPages,
    );

    emit(
      current.copyWith(
        messages: messagesData.messages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
      ),
    );
  }

  Future<void> _onLoadMoreMessages(
    LoadMoreMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final current = state as ChatDetailReady;

    if (current.isLoadingMore || !current.hasMoreMessages) return;

    emit(current.copyWith(isLoadingMore: true));

    final nextPage = current.currentPage + 1;
    final result = await _repo.getChatMessages(chatId, page: nextPage);

    if (result.data == null) {
      emit(current.copyWith(isLoadingMore: false));
      return;
    }

    final messagesData = result.data!;

    // Append older messages to the end of the list
    final allMessages = [...current.messages, ...messagesData.messages];

    // Update cache
    _cache.updateMessages(
      chatId: chatId,
      messages: allMessages,
      currentPage: messagesData.page,
      totalPages: messagesData.totalPages,
      hasMoreMessages: messagesData.page < messagesData.totalPages,
    );

    emit(
      current.copyWith(
        messages: allMessages,
        currentPage: messagesData.page,
        totalPages: messagesData.totalPages,
        hasMoreMessages: messagesData.page < messagesData.totalPages,
        isLoadingMore: false,
      ),
    );
  }

  /// Save current state to cache before closing
  void _saveToCache() {
    if (state is ChatDetailReady) {
      final current = state as ChatDetailReady;
      _cache.cacheData(
        chatId: chatId,
        chat: current.chat,
        messages: current.messages,
        currentPage: current.currentPage,
        totalPages: current.totalPages,
        hasMoreMessages: current.hasMoreMessages,
      );
    }
  }

  @override
  Future<void> close() async {
    _saveToCache();
    await _socketSub?.cancel();
    return super.close();
  }
}
