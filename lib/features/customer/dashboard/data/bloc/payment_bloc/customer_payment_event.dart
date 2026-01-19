part of 'customer_payment_bloc.dart';

abstract class CustomerPaymentEvent extends Equatable {
  const CustomerPaymentEvent();

  @override
  List<Object?> get props => [];
}

class CustomerInitWalletFundingEvent extends CustomerPaymentEvent {
  const CustomerInitWalletFundingEvent({
    required this.amount,
    required this.userType,
  });

  final int amount;
  final String userType;

  @override
  List<Object?> get props => [amount, userType];
}

class CustomerVerifyWalletFundingEvent extends CustomerPaymentEvent {
  const CustomerVerifyWalletFundingEvent(this.reference);

  final String reference;

  @override
  List<Object?> get props => [reference];
}

class CustomerInitServicePaymentEvent extends CustomerPaymentEvent {
  const CustomerInitServicePaymentEvent({
    required this.amount,
    required this.email,
    required this.currency,
    required this.callbackUrl,
  });

  final int amount;
  final String email;
  final String currency;
  final String callbackUrl;

  @override
  List<Object?> get props => [amount, email, currency, callbackUrl];
}

class CustomerInitServiceRequestPaymentEvent extends CustomerPaymentEvent {
  const CustomerInitServiceRequestPaymentEvent({
    required this.chatId,
    required this.invoiceMessageId,
    required this.paymentMethod,
  });

  final int chatId;
  final int invoiceMessageId;
  final String paymentMethod;

  @override
  List<Object?> get props => [chatId, invoiceMessageId, paymentMethod];
}

// class CustomerVerifyServicePaymentEvent extends CustomerPaymentEvent {
//   const CustomerVerifyServicePaymentEvent(this.reference);

//   final String reference;

//   @override
//   List<Object?> get props => [reference];
// }

// New event for verifying service request payment
class CustomerVerifyServiceRequestPaymentEvent extends CustomerPaymentEvent {
  const CustomerVerifyServiceRequestPaymentEvent(this.reference);

  final String reference;

  @override
  List<Object?> get props => [reference];
}
class CustomerInitAdvertisementPaymentEvent extends CustomerPaymentEvent {
  const CustomerInitAdvertisementPaymentEvent({
    required this.amount,
    required this.email,
    required this.currency,
    required this.callbackUrl,
  });

  final int amount;
  final String email;
  final String currency;
  final String callbackUrl;

  @override
  List<Object?> get props => [amount, email, currency, callbackUrl];
}

class CustomerVerifyAdvertisementPaymentEvent extends CustomerPaymentEvent {
  const CustomerVerifyAdvertisementPaymentEvent(this.reference);

  final String reference;

  @override
  List<Object?> get props => [reference];
}
