part of 'customer_payment_bloc.dart';

abstract class CustomerPaymentState extends Equatable {
  const CustomerPaymentState();

  @override
  List<Object?> get props => [];
}

class CustomerPaymentInitialState extends CustomerPaymentState {}

class AdvertisementPaymentLoadingState extends CustomerPaymentState {}

class AdvertisementPaymentInitiatedState extends CustomerPaymentState {
  const AdvertisementPaymentInitiatedState(this.payment);

  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

class AdvertisementPaymentVerifiedState extends CustomerPaymentState {
  const AdvertisementPaymentVerifiedState(this.verification);

  final PaymentVerification verification;

  @override
  List<Object?> get props => [verification];
}

class AdvertisementPaymentFailureState extends CustomerPaymentState {
  const AdvertisementPaymentFailureState(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}


class WalletFundingLoadingState extends CustomerPaymentState {}

class WalletFundingInitiatedState extends CustomerPaymentState {
  const WalletFundingInitiatedState(this.payment);

  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

class WalletFundingVerifiedState extends CustomerPaymentState {
  const WalletFundingVerifiedState(this.verification);

  final PaymentVerification verification;

  @override
  List<Object?> get props => [verification];
}

class WalletFundingFailureState extends CustomerPaymentState {
  const WalletFundingFailureState(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class ServicePaymentLoadingState extends CustomerPaymentState {}

class ServicePaymentInitiatedState extends CustomerPaymentState {
  const ServicePaymentInitiatedState(this.payment);

  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

class ServicePaymentVerifiedState extends CustomerPaymentState {
  const ServicePaymentVerifiedState(this.verification);

  final PaymentVerification verification;

  @override
  List<Object?> get props => [verification];
}

class ServicePaymentFailureState extends CustomerPaymentState {
  const ServicePaymentFailureState(this.error);

  final String error;

  @override
  List<Object?> get props => [error];
}

class ServiceRequestPaymentInitiatedState extends CustomerPaymentState {
  const ServiceRequestPaymentInitiatedState(this.payment);

  final PaymentResponse payment;

  @override
  List<Object?> get props => [payment];
}

class ServiceRequestPaymentCompletedState extends CustomerPaymentState {
  const ServiceRequestPaymentCompletedState({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class ServiceRequestPaymentVerifying extends CustomerPaymentState {}
