part of 'customer_advertisement_bloc.dart';

sealed class CustomerAdvertisementEvent extends Equatable {
  const CustomerAdvertisementEvent();

  @override
  List<Object> get props => [];
}

class CustomerFetchAdvertisement extends CustomerAdvertisementEvent{}

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
}
