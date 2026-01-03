import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_response.dart';
import 'package:resq360/features/customer/chat/data/models/chat/message_response.dart';
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
  })  : _repo = chatRepo ?? ChatRepo(),
        _socket = socket ?? ChatSocketService.instance,
        super(ChatDetailInitial()) {
    on<OpenChatDetail>(_onOpenChatDetail);
    on<SendTextMessage>(_onSendMessage);
    on<SendInvoiceMessage>(_onSendInvoiceMessage);
    on<RefreshMessages>(_onRefreshMessages);
    on<_IncomingMessage>(_onIncomingMessage);
  }

  final int chatId;
  final ChatRepo _repo;
  final ChatSocketService _socket;
  StreamSubscription<dynamic> ? _socketSub;

  Future<void> _onOpenChatDetail(
    OpenChatDetail event,
    Emitter<ChatDetailState> emit,
  ) async {
    emit(ChatDetailLoading());

    final result = await _repo.getChatById(event.chatId);

    if (result.data == null) {
      emit(ChatDetailFailure(result.error ?? 'Failed to load chat'));
      return;
    }

    await _connectSocket();

    final chat = result.data!;
    emit(
      ChatDetailReady(
        chat: chat,
        messages: chat.messages ?? [],
      ),
    );
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
  Future<void> _onSendInvoiceMessage(
  SendInvoiceMessage event,
  Emitter<ChatDetailState> emit,
) async {
  final current = state;
  if (current is! ChatDetailReady) return;

  // 1️⃣ Optimistic invoice message
  // final optimisticMessage = MessageResponse(
  //   id: DateTime.now().millisecondsSinceEpoch * -1,
  //   chatId: current.chat.id,
  //   senderType: 'PROVIDER',
  //   messageType: 'SYSTEM',
  //   content: event.invoice.description ?? 'Invoice',
  //   createdAt: DateTime.now(),
  //   metadata: Metadata(
  //     type: 'INVOICE',
  //     amount: event.invoice.amount,
  //     currency: event.invoice.currency,
  //     invoiceId: event.invoice.invoiceId,
  //     description: event.invoice.description,
  //   ),
  // );

  // emit(
  //   current.copyWith(
  //     messages: [
  //       optimisticMessage,
  //       ...current.messages,
  //     ],
  //   ),
  // );

 
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
        // ...current.messages.where(
        //   (m) => m.id != optimisticMessage.id,
        // ),
      ],
    ),
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
