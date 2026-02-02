part of 'wallet_transaction_bloc.dart';

sealed class WalletTransactionsState extends Equatable {
  const WalletTransactionsState();
  
  @override
  List<Object?> get props => [];
}



class WalletTransactionsInitial extends WalletTransactionsState {}

class WalletTransactionsLoading extends WalletTransactionsState {}

class WalletTransactionsLoadingMore extends WalletTransactionsState {

  const WalletTransactionsLoadingMore({required this.transactions});
  final List<WalletTransaction> transactions;

  @override
  List<Object?> get props => [transactions];
}

class WalletTransactionsLoaded extends WalletTransactionsState {

  const WalletTransactionsLoaded({
    required this.transactions,
    required this.pagination,
    this.isRefresh = false,
  });
  final List<WalletTransaction> transactions;
  final Pagination pagination;
  final bool isRefresh;

  @override
  List<Object?> get props => [transactions, pagination, isRefresh];
}

class WalletTransactionsError extends WalletTransactionsState {

  const WalletTransactionsError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}

class WithdrawalProcessing extends WalletTransactionsState {}

class WithdrawalSuccess extends WalletTransactionsState {

  const WithdrawalSuccess(this.payout);
  final PayoutResponse payout;
}

class WithdrawalFailure extends WalletTransactionsState {
  const WithdrawalFailure(this.error);
  final String error;
}
