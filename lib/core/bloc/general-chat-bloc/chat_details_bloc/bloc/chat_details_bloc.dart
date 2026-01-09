import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
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
  }) : _repo = chatRepo ?? ChatRepo(),
       _socket = socket ?? ChatSocketService.instance,
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
  StreamSubscription<dynamic>? _socketSub;

  Future<void> _onOpenChatDetail(
    OpenChatDetail event,
    Emitter<ChatDetailState> emit,
  ) async {
    try {
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

    emit(
      current.copyWith(
        messages: [
          localMessage,
          ...current.messages,
        ],
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

    emit(
      current.copyWith(
        messages: [
          result.data!,
          ...current.messages.where(
            (m) => m.id != localMessage.id,
          ),
        ],
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
    emit(
      current.copyWith(
        messages: [localMessage, ...current.messages],
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

    emit(
      current.copyWith(
        messages: [event.message, ...confirmedMessages],
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

  @override
  Future<void> close() async {
    await _socketSub?.cancel();
    return super.close();
  }
}
