part of 'customer_bank_bloc.dart';

sealed class CustomerBankState extends Equatable {
  const CustomerBankState();
  
  @override
  List<Object> get props => [];
}

final class CustomerBankInitial extends CustomerBankState {}
final class CustomerBankLoading extends CustomerBankState{}
