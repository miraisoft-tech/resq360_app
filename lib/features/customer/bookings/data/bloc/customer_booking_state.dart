part of 'customer_booking_bloc.dart';

sealed class CustomerBookingState extends Equatable {
  const CustomerBookingState();
  
  @override
  List<Object?> get props => [];
}

final class CustomerBookingInitial extends CustomerBookingState {}

class CustomerBookingLoading extends CustomerBookingState {}

class CustomerBookingLoaded extends CustomerBookingState {

  const CustomerBookingLoaded(this.bookings);
  final List<Bookings> bookings;

  @override
  List<Object?> get props => [bookings];
}

class CustomerBookingError extends CustomerBookingState {
  const CustomerBookingError({required this.error});
  final String error;
}
