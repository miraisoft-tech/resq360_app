part of 'bank_bloc.dart';

sealed class BankEvent extends Equatable {
  const BankEvent();

  @override
  List<Object> get props => [];
}


class BankAddAccount extends BankEvent {
  const BankAddAccount({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
    required this.currency,
    this.routingNumber,
    this.swiftCode,
    this.isDefault = true,
  });
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String bankCode;
  final String currency;
  final String? routingNumber;
  final String? swiftCode;
  final bool isDefault;

  @override
  List<Object> get props => [
        accountName,
        accountNumber,
        bankName,
        bankCode,
        currency,
        routingNumber ?? '',
        swiftCode ?? '',
        isDefault,
      ];
}

class BankValidateAccount extends BankEvent {

  const BankValidateAccount({
    required this.accountNumber,
    required this.bankCode,
  });
  final String accountNumber;
  final String bankCode;
}

class BankUpdateAccount extends BankEvent {

  const BankUpdateAccount({
    required this.id,
    this.accountName,
    this.accountNumber,
  });
  final int id;
  final String? accountName;
  final String? accountNumber;
}


class BankFetchAccounts extends BankEvent {}

class BankSetDefaultAccount extends BankEvent {
  const BankSetDefaultAccount({required this.bankAccountId});
  final int bankAccountId;

  @override
  List<Object> get props => [bankAccountId];
}

class BankVerifyAndRegisterAccount extends BankEvent {
  const BankVerifyAndRegisterAccount({required this.bankAccountId});
  final String bankAccountId;

  @override
  List<Object> get props => [bankAccountId];
}

class UpdateBankAccount extends BankEvent {
  const UpdateBankAccount({required this.bankDetails});
  final BankDetails bankDetails;

  @override
  List<Object> get props => [bankDetails];
}

class DeleteBankAccount extends BankEvent {
  const DeleteBankAccount({required this.bankAccountId});
  final int bankAccountId;

  @override
  List<Object> get props => [bankAccountId];
}

class GetBanks extends BankEvent{}
