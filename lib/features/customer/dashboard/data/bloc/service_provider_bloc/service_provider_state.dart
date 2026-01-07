part of 'service_provider_bloc.dart';

sealed class ServiceProviderState extends Equatable {
  const ServiceProviderState();
  
  @override
  List<Object?> get props => [];
}

final class ServiceProviderInitial extends ServiceProviderState {}

class ServiceProvidersLoading extends ServiceProviderState {}
class PingProvidersLoading extends ServiceProviderState {}


class ServiceProvidersLoaded extends ServiceProviderState {

  const ServiceProvidersLoaded({required this.providers});
  final List<ServiceProvider> providers;

  @override
  List<Object?> get props => [providers];
}

class ServiceProviderInfoLoaded extends ServiceProviderState {

  const ServiceProviderInfoLoaded({required this.info});
  final Service info;

  @override
  List<Object?> get props => [info];
}

class PingProvidersSuccess extends ServiceProviderState {}


class ServiceProvidersError extends ServiceProviderState {

  const ServiceProvidersError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
