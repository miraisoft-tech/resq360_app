import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/authentication/view_models/auth_vm.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';

part 'customer_chat_event.dart';
part 'customer_chat_state.dart';

class CustomerChatBloc extends Bloc<CustomerChatEvent, CustomerChatState> {
  CustomerChatBloc() : super(CustomerChatInitial()) {
    on<ConnectChatSocketEvent>(_onConnectSocket);
    on<CreateChatEvent>(_onCreateChat);
    on<GetChatsEvent>(_onGetChats);
    on<SendMessageEvent>(_onSendMessage);
    on<GetChatMessagesEvent>(_onGetMessages);
    on<MarkMessageAsReadEvent>(_onMarkAsRead);
    on<LeaveChatEvent>(_onLeaveChat);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
  }

  final ChatRepo _chatRepo = ChatRepo();
  final ChatSocketService _socket = ChatSocketService.instance;

  /// 🔌 Connect to Socket
  Future<void> _onConnectSocket(
    ConnectChatSocketEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    emit(ConnectingSocketState());
    await _socket.connect();
    _socket.messageStream.listen((message) {
      add(NewMessageReceivedEvent(message));
    });
    emit(CustomerChatSocketConnected());
  }

  /// 💬 Create Chat
  Future<void> _onCreateChat(
    CreateChatEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    emit(CreatingChatState());
    final result = await _chatRepo.createChat(chatRequest: event.chatRequest);
    if (result.data != null) {
      emit(CustomerChatLoadedState(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Unable to create chat'));
    }
  }

  /// 📜 Get Chats
  Future<void> _onGetChats(
    GetChatsEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    emit(FetchingChatsState());
    final result = await _chatRepo.getChats();
    if (result.data != null) {
      emit(CustomerChatListLoadedState(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Failed to fetch chats'));
    }
  }

  /// 📨 Send Message (instant)
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    final auth = CustomerAuthProvider.instance.authInfo;
    final currentUserId = auth?.user.id;
    //  create a local message to show in UI for now
    final localMessage = MessageResponse(
      id: DateTime.now().millisecondsSinceEpoch,
      chatId: event.messageRequest.chatId,
      content: event.messageRequest.content,
      messageType: event.messageRequest.messageType,
      senderId: currentUserId,
      senderType: 'USER',
      createdAt: DateTime.now(),
    );
    emit(NewMessageState(localMessage));
    final result = await _chatRepo.sendMessage(messageRequest: event.messageRequest);

  if (result.data != null) {
     emit(NewMessageState(result.data!));
    emit(const MessageSent());
  } else {
    emit(const CustomerChatErrorState('Failed to send message'));
  }
  }

  /// 🧾 Get Messages
  Future<void> _onGetMessages(
    GetChatMessagesEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    emit(FetchingMessagesState());
    final result = await _chatRepo.getChatMessages(event.chatId);
    if (result.data != null) {
      emit(MessagesLoaded(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Failed to load messages'));
    }
  }

  /// 👁️ Mark Message as Read (no loader)
  Future<void> _onMarkAsRead(
    MarkMessageAsReadEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    final result = await _chatRepo.markMessageAsRead(event.messageId);
    if (result.data != null) {
      emit(MessageRead(event.messageId));
    } else {
      emit(
        CustomerChatErrorState(
          result.error ?? 'Failed to mark message as read',
        ),
      );
    }
  }

  /// 🚪 Leave Chat
  Future<void> _onLeaveChat(
    LeaveChatEvent event,
    Emitter<CustomerChatState> emit,
  ) async {
    emit(LeavingChatState());
    final result = await _chatRepo.leaveChat(event.chatId);
    if (result.error == null) {
      emit(ChatLeft());
    } else {
      emit(CustomerChatErrorState(result.error!));
    }
  }

  /// 🔔 New Message
  void _onNewMessageReceived(
    NewMessageReceivedEvent event,
    Emitter<CustomerChatState> emit,
  ) {
    emit(NewMessageState(event.message));
  }
}
