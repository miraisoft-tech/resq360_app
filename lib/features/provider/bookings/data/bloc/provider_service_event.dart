part of 'provider_service_bloc.dart';

sealed class ProviderServiceEvent extends Equatable {
  const ProviderServiceEvent();

  @override
  List<Object> get props => [];
}

class ProviderFetchBookings extends ProviderServiceEvent {
   const ProviderFetchBookings({required this.status});
  final String status;
}
