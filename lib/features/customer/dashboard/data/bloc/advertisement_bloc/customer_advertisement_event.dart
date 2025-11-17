part of 'customer_advertisement_bloc.dart';

sealed class CustomerAdvertisementEvent extends Equatable {
  const CustomerAdvertisementEvent();

  @override
  List<Object> get props => [];
}

class CustomerFetchAdvertisement extends CustomerAdvertisementEvent{}
