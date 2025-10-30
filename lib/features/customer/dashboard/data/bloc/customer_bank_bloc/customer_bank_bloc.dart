import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';

part 'Customer_bank_event.dart';
part 'customer_bank_state.dart';

class CustomerBankBloc extends Bloc<ConsumerBankEvent, CustomerBankState> {
  CustomerBankBloc() : super(CustomerBankInitial()) {
    on<BankAddAccount>(_onAddBankAccount);
on<BankFetchAccounts>(_onFetchBankAccounts);
on<BankSetDefaultAccount>(_onSetDefaultBankAccount);
on<BankVerifyAndRegisterAccount>(_onVerifyAndRegisterBankAccount);
  }
  Future<void> _onAddBankAccount(
    BankAddAccount event,
    Emitter<CustomerBankState> emit,
  ) async {
    emit(CustomerBankLoading());
    try {
      // Call repository to add bank account
      // final result = await bankRepo.addBankAccount(...);
      // if (result.isSuccess) {
      //   emit(CustomerbankAccountAdded());
      // } else {
      //   emit(CustomerBankFailure());
      // }
    } on Exception catch (e) {
        log('Error adding bank account: $e');
      emit(CustomerBankFailure());
    }
  }

  Future<void> _onFetchBankAccounts(
    BankFetchAccounts event,
    Emitter<CustomerBankState> emit,
  ) async {
    emit(CustomerBankLoading());
    try {
      // Call repository to fetch bank accounts
      // final result = await bankRepo.fetchBankAccounts();
      // if (result.isSuccess) {
      //   emit(CustomerBankAccountsFetched());
      // } else {
      //   emit(CustomerBankFailure());
      // }
    } on Exception catch (e) {
        log('Error fetching bank account: $e');

      emit(CustomerBankFailure());
    }
  }

  Future<void> _onSetDefaultBankAccount(
    BankSetDefaultAccount event,
    Emitter<CustomerBankState> emit,
  ) async {
    emit(CustomerBankLoading());
    try {
      // Call repository to set default bank account
      // final result = await bankRepo.setDefaultBankAccount(...);
      // if (result.isSuccess) {
      //   emit(CustomerDefaultBankAccountSetSuccesful());
      // } else {
      //   emit(CustomerBankFailure());
      // }
    } on Exception catch (e) {
        log('Error setting default account: $e');

      emit(CustomerBankFailure());
    }
  }
  Future<void> _onVerifyAndRegisterBankAccount(
    BankVerifyAndRegisterAccount event,
    Emitter<CustomerBankState> emit,
  ) async {
    emit(CustomerBankLoading());
    try {
      // Call repository to verify and register bank account
      // final result = await bankRepo.verifyAndRegisterBankAccount(...);
      // if (result.isSuccess) {
      //   emit(CustomerBankVerifiedAndRegisteredWithPaystack());
      // } else {
      //   emit(CustomerBankFailure());
      // }
    } on Exception catch (e) {
        log('Error verifying bank account: $e');
      emit(CustomerBankFailure());
    }
  }
    
}
