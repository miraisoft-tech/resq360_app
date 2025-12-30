import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/send_message_request.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';

part 'chat_details_event.dart';
part 'chat_details_state.dart';


class ChatDetailBloc extends Bloc<ChatDetailEvent, ChatDetailState> {
  ChatDetailBloc({
    required this.chatId,
    ChatRepo? chatRepo,
    ChatSocketService? socket,
  })  : _repo = chatRepo ?? ChatRepo(),
        _socket = socket ?? ChatSocketService.instance,
        super(ChatDetailInitial()) {
    on<OpenChatDetail>(_onOpenChat);
    on<SendTextMessage>(_onSendMessage);
    on<RefreshMessages>(_onRefreshMessages);
    on<_IncomingMessage>(_onIncomingMessage);
  }

  final int chatId;
  final ChatRepo _repo;
  final ChatSocketService _socket;
  StreamSubscription<dynamic> ? _socketSub;

  Future<void> _onOpenChat(
    OpenChatDetail event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(ChatDetailLoading());

    try {
      final chatResult = await _repo.getChatById(chatId);
      final messagesResult = await _repo.getChatMessages(chatId);

      if (chatResult.data == null || messagesResult.data == null) {
        emit(
          ChatDetailFailure(
            chatResult.error ?? 'Failed to load chat',
          ),
        );
        return;
      }

      await _connectSocket();

      emit(
        ChatDetailReady(
          messages: messagesResult.data!.messages, chatId: chatResult.data!.id!, title: chatResult.data!.title!,
        ),
      );
    } on Exception catch (e) {
      emit(ChatDetailFailure(e.toString()));
    }
  }

  Future<void> _connectSocket() async {
    if (!_socket.isConnected) {
      await _socket.connect();
    }

    await _socket.joinChat(chatId);

    await _socketSub?.cancel();
    _socketSub = _socket.messageStream.listen(
      (msg) {
        if (msg.chatId == chatId) {
          add(_IncomingMessage(msg));
        }
      },
    );
  }

  Future<void> _onSendMessage(
    SendTextMessage event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

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

    emit(
      current.copyWith(
        messages: [event.message, ...current.messages],
      ),
    );
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<ChatDetailState> emit,
  ) async {
    if (state is! ChatDetailReady) return;

    final result = await _repo.getChatMessages(chatId);
    if (result.data == null) return;

    emit(
      (state as ChatDetailReady).copyWith(
        messages: result.data!.messages,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _socketSub?.cancel();
    return super.close();
  }
}
