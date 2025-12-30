part of 'wallet_transaction_bloc.dart';

sealed class WalletTransactionsEvent extends Equatable {
  const WalletTransactionsEvent();

  @override
  List<Object> get props => [];
}


class FetchWalletTransactions extends WalletTransactionsEvent {}

class RefreshWalletTransactions extends WalletTransactionsEvent {}

class LoadMoreWalletTransactions extends WalletTransactionsEvent {}
