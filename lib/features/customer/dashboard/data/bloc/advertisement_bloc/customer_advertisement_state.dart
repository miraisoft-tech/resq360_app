part of 'customer_advertisement_bloc.dart';

sealed class CustomerAdvertisementState extends Equatable {
  const CustomerAdvertisementState();

  @override
  List<Object?> get props => [];
}

final class CustomerAdvertisementInitial extends CustomerAdvertisementState {}

final class CustomerAdvertisementLoading extends CustomerAdvertisementState {}

final class CustomerAdvertisementFetched extends CustomerAdvertisementState {
  const CustomerAdvertisementFetched({required this.adverisementList});

  final List<Advertisement> adverisementList;

  @override
  List<Object?> get props => [adverisementList];
}

class CustomerAdvertisementCreated extends CustomerAdvertisementState {}

final class CustomerAdvertisementError extends CustomerAdvertisementState {
  const CustomerAdvertisementError({required this.error});

  final String error;

  @override
  List<Object?> get props => [error];
}
