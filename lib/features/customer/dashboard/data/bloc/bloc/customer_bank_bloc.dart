import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';

part 'Customer_bank_event.dart';
part 'customer_bank_state.dart';

class BankBlocBloc extends Bloc<BankBlocEvent, CustomerBankState> {
  BankBlocBloc() : super(CustomerBankInitial()) {
    on<BankBlocEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
