part of 'bank_bloc.dart';

sealed class BankState extends Equatable {
  const BankState();
  
  @override
  List<Object> get props => [];
}

final class BankInitial extends BankState {}

final class BankLoading extends BankState{}
final class LocalBanksLoading extends BankState{}

final class BankAccountAdded extends BankState{}

class BankAccountValidating extends BankState {}

class BankAccountValidated extends BankState {

  const BankAccountValidated({required this.accountName});
  final String accountName;
}

final class BankAccountsFetched extends BankState{
  const BankAccountsFetched({required this.bankAcounts});

   final List<BankDetails> bankAcounts;
}
final class BankVerifiedAndRegisteredWithPaystack extends BankState{}
final class CustomerDefaultBankAccountSetSuccesful extends BankState{}
final class BankAccountUpdated extends BankState{}
final class BankAccountDeleted extends BankState{}



final class BankFailure extends BankState{
  const BankFailure({required this.error});

  final String error;
}
final class BankAccountAddedFailed extends BankState{}
final class BankAccountsFetchedfailed extends BankState{}
final class LocalBanksFetched extends BankState{
    const LocalBanksFetched(this.banks);

  final List<BankModel> banks;
}
