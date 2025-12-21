part of 'customer_payment_bloc.dart';

sealed class CustomerPaymentState extends Equatable {
  const CustomerPaymentState();

  @override
  List<Object?> get props => [];
}

final class CustomerPaymentInitialState extends CustomerPaymentState {}


final class WalletFundingLoadingState extends CustomerPaymentState {}

final class WalletFundingInitiatedState extends CustomerPaymentState {
  const WalletFundingInitiatedState(this.payment);
  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

final class WalletFundingVerifiedState extends CustomerPaymentState {
  const WalletFundingVerifiedState(this.verification);
  final PaymentVerification verification;

  @override
  List<Object?> get props => [verification];
}

final class WalletFundingFailureState extends CustomerPaymentState {
  const WalletFundingFailureState(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}


final class ServicePaymentLoadingState extends CustomerPaymentState {}

final class ServicePaymentInitiatedState extends CustomerPaymentState {
  const ServicePaymentInitiatedState(this.payment);
  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

final class ServicePaymentVerifiedState extends CustomerPaymentState {
  const ServicePaymentVerifiedState(this.verification);
  final PaymentVerification verification;

  @override
  List<Object?> get props => [verification];
}

final class ServicePaymentFailureState extends CustomerPaymentState {
  const ServicePaymentFailureState(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
