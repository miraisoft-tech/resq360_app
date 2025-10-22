part of 'customer_services_bloc.dart';

abstract class CustomerServicesState extends Equatable {
  const CustomerServicesState();
  @override
  List<Object?> get props => [];
}

class CustomerServicesInitial extends CustomerServicesState {}
class CustomerServicesLoading extends CustomerServicesState {}

class CustomerServicesLoaded extends CustomerServicesState {
  const CustomerServicesLoaded({required this.services});
  final List<Service> services;
}

class CustomerProvidersLoaded extends CustomerServicesState {
  const CustomerProvidersLoaded({required this.providers});
  final List<ServiceProvider> providers;
}

class CustomerServiceInfoLoaded extends CustomerServicesState {
  const CustomerServiceInfoLoaded({required this.info});
  final Service info;
}

class CustomerServiceCreated extends CustomerServicesState {
  const CustomerServiceCreated({required this.service});
  final Service service;
}

class CustomerServicesError extends CustomerServicesState {
  const CustomerServicesError({required this.error});
  final String error;
}
