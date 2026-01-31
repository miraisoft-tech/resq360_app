part of 'customer_advertisement_bloc.dart';

abstract class CustomerAdvertisementState extends Equatable {
  const CustomerAdvertisementState();

  @override
  List<Object?> get props => [];
}

class CustomerAdvertisementInitial extends CustomerAdvertisementState {}

class CustomerAdvertisementLoading extends CustomerAdvertisementState {}

class CustomerAdvertisementFetched extends CustomerAdvertisementState {
  const CustomerAdvertisementFetched({
    this.providerAds = const [],
    this.adminAds = const [],
  });
  final List<Advertisement> providerAds;
  final List<Advertisement> adminAds;

  @override
  List<Object?> get props => [providerAds, adminAds];
}

// class ProviderActiveAdvertisementsFetched extends CustomerAdvertisementState {
//   const ProviderActiveAdvertisementsFetched({required this.advertisements});

//   final List<Advertisement> advertisements;

//   @override
//   List<Object?> get props => [advertisements];
// }

// class AdvertisementCreated extends CustomerAdvertisementState {}

class CustomerAdvertisementError extends CustomerAdvertisementState {
  const CustomerAdvertisementError({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}

// class AdvertisementFetchPriceLoading extends CustomerAdvertisementState {}

// class AdvertisementPriceFetched extends CustomerAdvertisementState {
//   const AdvertisementPriceFetched({required this.price});

//   final int? price;

//   @override
//   List<Object?> get props => [price];
// }

// class AdvertisementPaymentInitiatedState extends CustomerAdvertisementState {
//   const AdvertisementPaymentInitiatedState(this.payment);

//   final PaymentResponse payment;

//   @override
//   List<Object?> get props => [payment];
// }

// class AdvertisementPaymentVerifying extends CustomerAdvertisementState {}

// class AdvertisementPaymentVerified extends CustomerAdvertisementState {
//   const AdvertisementPaymentVerified({required this.message});

//   final String message;

//   @override
//   List<Object?> get props => [message];
// }
