part of 'provider_ongoing_bloc.dart';

sealed class ProviderOngoingState extends Equatable {
  const ProviderOngoingState();

  @override
  List<Object> get props => [];
}

class ProviderOngoingInitial extends ProviderOngoingState {}

class ProviderOngoingLoading extends ProviderOngoingState {}

class ProviderOngoingLoaded extends ProviderOngoingState {
  const ProviderOngoingLoaded(this.bookings, {this.label = 'Ongoing Service'});
  final List<Bookings> bookings;
  final String label;

  @override
  List<Object> get props => [bookings, label];
}

class ProviderOngoingError extends ProviderOngoingState {
  const ProviderOngoingError(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
