import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/chat/data/models/chat_model.dart';
import 'package:resq360/features/customer/chat/data/services/chat_repo.dart';

part 'customer_chat_event.dart';
part 'customer_chat_state.dart';
final ChatRepo _chatRepo = ChatRepo();
class CustomerChatBloc extends Bloc<CustomerChatEvent, CustomerChatState> {
  CustomerChatBloc() : super(CustomerChatInitial()) {
    on<CustomerChatEvent>((event, emit) { });
     on<CreateChatEvent>(_onCreateChat);
      on<GetChatsEvent>(_onGetChats);
      on<SendMessageEvent>(_onSendMessage);
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

  Future<void> _onSendMessage(SendMessageEvent event, Emitter<CustomerChatState> emit) async {
    emit(CustomerChatLoadingState());
    final result = await _chatRepo.sendMessage(messageRequest: event.messageRequest);
      if (result.data != null) {
      emit(MessageSent(result.data!));
    } else {
      emit(CustomerChatErrorState(result.error ?? 'Failed to send message'));
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
    final result = await _chatRepo.leaveChat( event.chatId);
    if (result.error == null) {
      emit(ChatLeft());
    } else {
      emit(CustomerChatErrorState(result.error!));
    }
  }
}
