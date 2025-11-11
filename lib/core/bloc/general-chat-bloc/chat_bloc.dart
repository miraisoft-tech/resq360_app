import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/chat_socket_service.dart';
import 'package:resq360/features/customer/chat/data/models/chat/chat_models.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc() : super(ChatInitial()) {
    on<ConnectChatSocketEvent>(_onConnectSocket);
    on<CreateChatEvent>(_onCreateChat);
    on<GetChatsEvent>(_onGetChats);
    on<SendMessageEvent>(_onSendMessage);
    on<GetChatMessagesEvent>(_onGetMessages);
    on<MarkMessageAsReadEvent>(_onMarkAsRead);
    on<LeaveChatEvent>(_onLeaveChat);
    on<NewMessageReceivedEvent>(_onNewMessageReceived);
    on<JoinChatEvent>(_onJoinChat);


    ChatSocketService.instance.messageStream.listen((message) {
      add(NewMessageReceivedEvent(message));
    });
  }

  final ChatRepo _chatRepo = ChatRepo();
  final ChatSocketService _socket = ChatSocketService.instance;


Future<void> _onConnectSocket(
  ConnectChatSocketEvent event,
  Emitter<ChatState> emit,
) async {
  emit(ConnectingSocketState());
  
  try {
    await _socket.connect();
    
    _socket.messageStream.listen((message) {
      add(NewMessageReceivedEvent(message));
    });
    
    debugPrint('Socket connected and ready');
    emit(ChatSocketConnected());
  } on Exception catch(e){
    debugPrint('Socket connection failed: $e');
    emit(ChatErrorState('Failed to connect: $e'));
  }
}

  
  Future<void> _onCreateChat(
    CreateChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(CreatingChatState());
    final result = await _chatRepo.createChat(chatRequest: event.chatRequest);
    if (result.data != null) {
      emit(ChatLoadedState(result.data!));
    } else {
      emit(ChatErrorState(result.error ?? 'Unable to create chat'));
    }
  }

   Future<void> _onGetChats(
    GetChatsEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(FetchingChatsState());
    final result = await _chatRepo.getChats();
    if (result.data != null) {
      emit(ChatListLoadedState(result.data!));
    } else {
      emit(ChatErrorState(result.error ?? 'Failed to fetch chats'));
    }
  }

  
  Future<void> _onSendMessage(
    SendMessageEvent event,
    Emitter<ChatState> emit,
  ) async {
    try {
      _socket.sendMessage(
        event.messageRequest,
      );
    } on Exception catch (e) {
      emit(ChatErrorState('Failed to send message $e'));
    }
  }

  
  Future<void> _onGetMessages(
    GetChatMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(FetchingMessagesState());
    final result = await _chatRepo.getChatMessages(event.chatId);
    if (result.data != null) {
      emit(MessagesLoaded(result.data!));
    } else {
      emit(ChatErrorState(result.error ?? 'Failed to load messages'));
    }
  }


  Future<void> _onMarkAsRead(
    MarkMessageAsReadEvent event,
    Emitter<ChatState> emit,
  ) async {
    final result = await _chatRepo.markMessageAsRead(event.messageId);
    if (result.data != null) {
      emit(MessageRead(event.messageId));
    } else {
      emit(
        ChatErrorState(
          result.error ?? 'Failed to mark message as read',
        ),
      );
    }
  }

 Future<void> _onJoinChat(
  JoinChatEvent event,
  Emitter<ChatState> emit,
) async {
  try {

    if (!_socket.isConnected) {
      emit(const ChatErrorState('Socket not connected'));
      return;
    }
    await _socket.joinChat(event.chatId);

    emit(ChatJoinedState(event.chatId));
  } on Exception catch (e, s) {
    emit(ChatErrorState('Failed to join chat: $e'));
    log('Join chat error: $e\n$s');
  }
}

    Future<void> _onLeaveChat(
    LeaveChatEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(LeavingChatState());
    final result = await _chatRepo.leaveChat(event.chatId);
    if (result.error == null) {
      emit(ChatLeft());
    } else {
      emit(ChatErrorState(result.error!));
    }
  }


  void _onNewMessageReceived(
    NewMessageReceivedEvent event,
    Emitter<ChatState> emit,
  ) {
    emit(NewMessageState(event.message));
  }
}
