part of 'customer_payment_bloc.dart';

sealed class CustomerPaymentState extends Equatable {
  const CustomerPaymentState();
  
  @override
  List<Object> get props => [];
}

final class CustomerPaymentInitialState extends CustomerPaymentState {}
final class CustomerPaymentLoadingState extends CustomerPaymentState {}
class CustomerPaymentSuccessState extends CustomerPaymentState {
  const CustomerPaymentSuccessState(this.payment);
  final PaymentResponse payment;

  @override
  List<Object> get props => [payment];
}
class CustomerPaymentFailureState extends CustomerPaymentState {
  const CustomerPaymentFailureState(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
class CustomerPaymentVerifiedState extends CustomerPaymentState {
  const CustomerPaymentVerifiedState(this.verification);
  final PaymentVerification verification;

  @override
  List<Object> get props => [verification];
}

class CustomerPaystackPaymentCompletedState extends CustomerPaymentState {}
