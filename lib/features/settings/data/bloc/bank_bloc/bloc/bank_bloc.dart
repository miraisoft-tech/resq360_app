import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bank/bank_details.model.dart';
import 'package:resq360/features/settings/data/models/banks_model.dart';
import 'package:resq360/features/settings/data/service/bank_service.dart';

part 'bank_event.dart';
part 'bank_state.dart';

final BankRepo bankRepo = BankRepo.instance;

class BankBloc extends Bloc<BankEvent, BankState> {
  BankBloc() : super(BankInitial()) {
    on<BankAddAccount>(_onAddBankAccount);
    on<BankFetchAccounts>(_onFetchBankAccounts);
    on<BankValidateAccount>(_onValidateBankAccount);
    on<BankSetDefaultAccount>(_onSetDefaultBankAccount);
    on<BankVerifyAndRegisterAccount>(_onVerifyAndRegisterBankAccount);
    on<GetBanks>(_getLocalBanks);
    on<DeleteBankAccount>(_onDeleteBankAccount);
    on<BankUpdateAccount>(_onUpdateBankAccount);
  }

  Future<void> _onAddBankAccount(
    BankAddAccount event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      final result = await bankRepo.addBankAccount(
        accountName: event.accountName,
        accountNumber: event.accountNumber,
        bankName: event.bankName,
        bankCode: event.bankCode,
        currency: event.currency,
      );
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

  Future<void> _onValidateBankAccount(
  BankValidateAccount event,
  Emitter<BankState> emit,
) async {
  emit(BankAccountValidating());

  try {
    final result = await bankRepo.validateBankAccount(
      accountNumber: event.accountNumber,
      bankCode: event.bankCode,
    );

    if (result.isSuccess) {
      final data = result.data!;
      final accountName = data['accountName'] as String;

      emit(BankAccountValidated(accountName: accountName));
    } else {
      emit(BankFailure(error: result.error!));
    }
  } on Exception catch (e) {
    emit(BankFailure(error: e.toString()));
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

      emit(BankFailure(error: '$e'));
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
        add(BankFetchAccounts());
      } else {
        emit(BankFailure(error: result.error!));
      }
    } on Exception catch (e) {
      log('Error setting default account: $e');

      emit(const BankFailure(error: ''));
    }
  }

  Future<void> _onUpdateBankAccount(
    BankUpdateAccount event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());

    try {
      final result = await bankRepo.updateBankAccount(
        bankAccountId: event.id,
        accountName: event.accountName,
        accountNumber: event.accountNumber,
      );

      if (result.isSuccess) {
        emit(BankAccountUpdated());
        add(BankFetchAccounts());
      } else {
        emit(BankFailure(error: result.error!));
      }
    } on Exception catch (e) {
      emit(BankFailure(error: e.toString()));
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

  Future<void> _onDeleteBankAccount(
    DeleteBankAccount event,
    Emitter<BankState> emit,
  ) async {
    emit(BankLoading());
    try {
      final result = await bankRepo.deleteBankAccount(event.bankAccountId);

      if (result.isSuccess) {
        emit(BankAccountDeleted());
        add(BankFetchAccounts());
      } else {
        emit(BankFailure(error: result.error!));
      }
    } on Exception catch (e) {
      emit(BankFailure(error: e.toString()));
    }
  }

  Future<void> _getLocalBanks(
    GetBanks event,
    Emitter<BankState> emit,
  ) async {
    final tempBankList = <BankModel>[];
    emit(LocalBanksLoading());
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/banks_list.json',
      );
      final json = jsonDecode(jsonString);

      if (json == null || json is! List) {
        emit(LocalBanksFetched(tempBankList));
        return;
      }

      final banksListJson = json;
      log('banks ${banksListJson.length}');

      for (final item in banksListJson) {
        if (item is Map<String, dynamic>) {
          tempBankList.add(BankModel.fromJson(item));
        }
      }

      tempBankList.sort((a, b) {
        final nameA = a.name ?? '';
        final nameB = b.name ?? '';
        return nameA.compareTo(nameB);
      });

      emit(LocalBanksFetched(tempBankList));
    } on Exception catch (e) {
      log('Error loading states: $e');
      emit(LocalBanksFetched(tempBankList));
    }
  }
}
