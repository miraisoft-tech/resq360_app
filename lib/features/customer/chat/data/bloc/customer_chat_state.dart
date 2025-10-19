part of 'customer_chat_bloc.dart';

sealed class CustomerChatState extends Equatable {
  const CustomerChatState();
  
  @override
  List<Object> get props => [];
}

final class CustomerChatInitial extends CustomerChatState {}
