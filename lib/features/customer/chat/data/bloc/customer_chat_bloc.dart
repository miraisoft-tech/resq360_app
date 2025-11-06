import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';

part 'customer_chat_event.dart';
part 'customer_chat_state.dart';

final ChatRepo _chatRepo = ChatRepo();
final UploadService uploadService = UploadService.instance;


class CustomerChatBloc extends Bloc<CustomerChatEvent, CustomerChatState> {
  CustomerChatBloc() : super(CustomerChatInitial()) {
    on<CreateChatEvent>(_onCreateChat);
    on<GetChatsEvent>(_onGetChats);
    on<SendMessageEvent>(_onSendMessage);
    on<SendFileMessageEvent>(_onSendFileMessage);
    on<GetChatMessagesEvent>(_onGetMessages);
    on<MarkMessageAsReadEvent>(_onMarkAsRead);
    on<LeaveChatEvent>(_onLeaveChat);
  }

  Future<void> _onCreateChat(CreateChatEvent event, Emitter<CustomerChatState> emit) async {
    emit(CustomerChatLoadingState());
    final result = await _chatRepo.createChat(chatRequest: event.chatRequest);

    if (result.data != null) {
      emit(CustomerChatLoadedState(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Unable to create chat'));
    }
  }

  Future<void> _onGetChats(GetChatsEvent event, Emitter<CustomerChatState> emit) async {
    emit(CustomerChatLoadingState());
    final result = await _chatRepo.getChats();

    if (result.data != null) {
      emit(CustomerChatListLoadedState(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Failed to fetch chats'));
    }
  }

Future<void> _onSendMessage(
  SendMessageEvent event,
  Emitter<CustomerChatState> emit,
) async {
  ChatMessagesResponse? existing;
  if (state is MessagesLoaded) {
    existing = (state as MessagesLoaded).messages;
  }

  emit(MessageSending());

  final result = await _chatRepo.sendMessage(messageRequest: event.messageRequest);

  if (result.data != null) {
    final newMessage = result.data!;

    // Compose current messages
    final current = <MessageResponse>[];
    if (existing != null) current.addAll(existing.messages);
    current.insert(0, newMessage);

    // Rebuild ChatMessagesResponse using existing metadata if present
    final updated = ChatMessagesResponse(
      messages: current,
      page: existing?.page ?? 1,
      limit: existing?.limit ?? current.length,
      total: existing?.total ?? current.length,
      totalPages: existing?.totalPages ?? 1,
    );

    emit(MessagesLoaded(updated));
  } else {
    emit(CustomerChatErrorState(result.error ?? 'Failed to send message'));
  }
}



  Future<void> _onSendFileMessage(
    SendFileMessageEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    emit(MessageSending());

    final uploadResult = await uploadService.uploadSingle(filePath: event.file.path);

    if (uploadResult.error != null) {
      emit(CustomerChatErrorState(uploadResult.error!));
      return;
    }

    final upload = uploadResult.data!;
    final messageRequest = SendMessageRequest(
      chatId: event.chatId,
      messageType: 'FILE',
      fileName: event.fileName,
      mimeType: event.mimeType,
      fileUrl: upload.url,
      fileSize: event.file.lengthSync(),
      content: '',
    );

    final sendResult = await _chatRepo.sendMessage(messageRequest: messageRequest);

    if (sendResult.error != null && sendResult.error!.isNotEmpty) {
      emit(CustomerChatErrorState(sendResult.error!));
    } else if (sendResult.data != null) {
      emit(MessageSent(sendResult.data!));
    } else {
      emit(const CustomerChatErrorState('Unknown error sending file message'));
    }
  }

  Future<void> _onGetMessages(GetChatMessagesEvent event, Emitter<CustomerChatState> emit) async {
    emit(CustomerChatLoadingState());
    final result = await _chatRepo.getChatMessages(event.chatId);

    if (result.data != null) {
      emit(MessagesLoaded(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Failed to load messages'));
    }
  }

  Future<void> _onMarkAsRead(MarkMessageAsReadEvent event, Emitter<CustomerChatState> emit) async {
    final result = await _chatRepo.markMessageAsRead(event.messageId);

    if (result.data != null) {
      emit(MessageRead(event.messageId));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Failed to mark message as read'));
    }
  }

  Future<void> _onLeaveChat(LeaveChatEvent event, Emitter<CustomerChatState> emit) async {
    emit(CustomerChatLoadingState());
    final result = await _chatRepo.leaveChat(event.chatId);

    if (result.error == null) {
      emit(ChatLeft());
    } else {
      emit(CustomerChatErrorState(result.error!));
    }
  }
}
