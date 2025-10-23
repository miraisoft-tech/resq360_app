import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'customer_chat_event.dart';
part 'customer_chat_state.dart';

class CustomerChatBloc extends Bloc<CustomerChatEvent, CustomerChatState> {
  CustomerChatBloc() : super(CustomerChatInitial()) {
    on<CustomerChatEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
