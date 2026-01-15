part of 'customer_advertisement_bloc.dart';

abstract class CustomerAdvertisementEvent extends Equatable {
  const CustomerAdvertisementEvent();

  @override
  List<Object?> get props => [];
}

class CustomerFetchAdvertisement extends CustomerAdvertisementEvent {}
class FetchProviderActiveAdvertisements extends CustomerAdvertisementEvent {
  const FetchProviderActiveAdvertisements({required this.providerId});

  final int providerId;
}


class CreateAdvertisement extends CustomerAdvertisementEvent {
  const CreateAdvertisement({
    required this.discount,
    required this.duration,
    required this.paymentMethod,
    required this.description,
  });

  final int discount;
  final int duration;
  final String paymentMethod;
  final String description;

  @override
  List<Object?> get props => [discount, duration, paymentMethod, description];
}

class FetchAdvertisementPrice extends CustomerAdvertisementEvent {}

class VerifyAdvertisementPayment extends CustomerAdvertisementEvent {
  const VerifyAdvertisementPayment({required this.reference});

  final String reference;

  @override
  List<Object?> get props => [reference];
}
