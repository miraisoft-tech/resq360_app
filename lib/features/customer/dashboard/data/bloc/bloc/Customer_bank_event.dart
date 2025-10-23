part of 'customer_bank_bloc.dart';

sealed class ConsumerBankEvent extends Equatable {
  const ConsumerBankEvent();

  @override
  List<Object> get props => [];
}

class BankAddAccount extends ConsumerBankEvent {
  const BankAddAccount({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
    required this.currency,
    this.routingNumber,
    this.swiftCode,
    this.isDefault = false,
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

class BankFetchAccounts extends ConsumerBankEvent {}

class BankSetDefaultAccount extends ConsumerBankEvent {
  const BankSetDefaultAccount({required this.bankAccountId});
  final String bankAccountId;

  @override
  List<Object> get props => [bankAccountId];
}

class BankVerifyAndRegisterAccount extends ConsumerBankEvent {
  const BankVerifyAndRegisterAccount({required this.bankAccountId});
  final String bankAccountId;

  @override
  List<Object> get props => [bankAccountId];
}

class UpdateBankAccount extends ConsumerBankEvent {
  const UpdateBankAccount({required this.bankDetails});
  final BankDetails bankDetails;

  @override
  List<Object> get props => [bankDetails];
}

class DeleteBankAccount extends ConsumerBankEvent {
  const DeleteBankAccount({required this.bankAccountId});
  final String bankAccountId;

  @override
  List<Object> get props => [bankAccountId];
}
