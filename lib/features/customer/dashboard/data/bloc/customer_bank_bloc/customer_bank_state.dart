part of 'customer_bank_bloc.dart';

sealed class CustomerBankState extends Equatable {
  const CustomerBankState();
  
  @override
  List<Object> get props => [];
}

final class CustomerBankInitial extends CustomerBankState {}
final class CustomerBankLoading extends CustomerBankState{}
final class CustomerbankAccountAdded extends CustomerBankState{}
final class CustomerBankAccountsFetched extends CustomerBankState{}
final class CustomerBankVerifiedAndRegisteredWithPaystack extends CustomerBankState{}
final class CustomerDefaultBankAccountSetSuccesful extends CustomerBankState{}
final class CustomerBankAccountUpdated extends CustomerBankState{}
final class CustomerBankAccountDeleted extends CustomerBankState{}


final class CustomerBankFailure extends CustomerBankState{}
