part of 'customer_payment_bloc.dart';


sealed class CustomerPaymentEvent extends Equatable {
  const CustomerPaymentEvent();

  @override
  List<Object> get props => [];
}

class CustomerInitializePaymentEvent extends CustomerPaymentEvent {
  const CustomerInitializePaymentEvent({required this.amount, required this.email, required this.currency, required this.callbackUrl});
  @override
  List<Object> get props => [];

  final int amount;
  final String email;
  final String currency;  
  final String callbackUrl;
}
class CustomerVerifyPaymentEvent extends CustomerPaymentEvent {
  const CustomerVerifyPaymentEvent(this.reference);
  @override
  List<Object> get props => [reference];

  final String reference;
}

class CustomerPaystackPaymentEvent extends CustomerPaymentEvent {}
