import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/settings/data/service/bank_service.dart';

part 'bank_event.dart';
part 'bank_state.dart';

final BankRepo bankRepo = BankRepo.instance;

class BankBloc extends Bloc<BankEvent, BankState> {
  BankBloc() : super(BankInitial()) {
on<BankAddAccount>(_onAddBankAccount);
on<BankFetchAccounts>(_onFetchBankAccounts);
on<BankSetDefaultAccount>(_onSetDefaultBankAccount);
on<BankVerifyAndRegisterAccount>(_onVerifyAndRegisterBankAccount);
  }
}


  Future<void> _onAddBankAccount(
    BankAddAccount event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      final result = await bankRepo.addBankAccount(accountName: event.accountName, accountNumber: event.accountNumber, bankName: event.bankName, bankCode: event.bankCode, currency: event.currency);
      if (result.isSuccess) {
        emit(BankAccountAdded());
      } else {
        emit(BankFailure(error: result.error!));
      }
    } on Exception catch (e) {
        log('Error adding bank account: $e');
      emit(BankFailure(error: '$e'));
    }
  }

  Future<void> _onFetchBankAccounts(
    BankFetchAccounts event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      final result = await bankRepo.fetchBankAccounts();
      if (result.isNotEmpty) {
        emit(BankAccountsFetched(bankAcounts: result));
      } else {
        emit(const BankAccountsFetched(bankAcounts: []));
      }
    } on Exception catch (e) {
        log('Error fetching bank account: $e');

      emit( BankFailure(error: '$e'));
    }
  }

  Future<void> _onSetDefaultBankAccount(
    BankSetDefaultAccount event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      final result = await bankRepo.setDefaultBankAccount(event.bankAccountId);
      if (result.isSuccess) {
        emit(CustomerDefaultBankAccountSetSuccesful());
      } else {
        emit(BankFailure(error: result.error!));
      }
    } on Exception catch (e) {
        log('Error setting default account: $e');

      emit(const BankFailure(error: ''));
    }
  }
  
  Future<void> _onVerifyAndRegisterBankAccount(
    BankVerifyAndRegisterAccount event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      // Call repository to verify and register bank account
      // final result = await bankRepo.verifyAndRegisterBankAccount(...);
      // if (result.isSuccess) {
      //   emit(BankVerifiedAndRegisteredWithPaystack());
      // } else {
      //   emit(BankFailure());
      // }
    } on Exception catch (e) {
        log('Error verifying bank account: $e');
      emit(const BankFailure(error: ''));
    }
  }
    
