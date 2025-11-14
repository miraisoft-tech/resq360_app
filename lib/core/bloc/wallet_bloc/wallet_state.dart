part of 'wallet_bloc.dart';

sealed class WalletState extends Equatable {
  const WalletState();
  
  @override
  List<Object> get props => [];
}

final class WalletInitial extends WalletState {}

final class FetchWalletLoading extends WalletState{}

final class FetchedWalletInfo extends WalletState{
    const FetchedWalletInfo({required this.wallet});

  final Wallet wallet;
}

final class FetchingWalletInfoError extends WalletState{
  const FetchingWalletInfoError({required this.error});

  final String? error;
}
