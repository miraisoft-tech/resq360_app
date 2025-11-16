part of 'provider_service_bloc.dart';

sealed class ProviderServiceState extends Equatable {
  const ProviderServiceState();
  
  @override
  List<Object> get props => [];
}

final class ProviderServiceInitial extends ProviderServiceState {}

class ProviderServicesInitial extends ProviderServiceState {}
class ProviderServicesLoading extends ProviderServiceState {}
class ProviderBookingsLoaded extends ProviderServiceState {
  const ProviderBookingsLoaded(this.bookings);
  final List<Bookings> bookings;
}
class ProviderServicesError extends ProviderServiceState {
  const ProviderServicesError(this.error);
  final String error;
}
