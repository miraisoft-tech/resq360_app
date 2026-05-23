part of 'service_detail_bloc.dart';

sealed class ServiceDetailState extends Equatable {
  const ServiceDetailState();

  @override
  List<Object?> get props => [];
}

class ServiceDetailInitial extends ServiceDetailState {}

class ServiceDetailLoading extends ServiceDetailState {}

class ServiceDetailLoaded extends ServiceDetailState {
  const ServiceDetailLoaded(this.booking);
  final Bookings booking;

  @override
  List<Object?> get props => [booking];
}

class ServiceDetailError extends ServiceDetailState {
  const ServiceDetailError(this.error);
  final String error;

  @override
  List<Object?> get props => [error];
}
