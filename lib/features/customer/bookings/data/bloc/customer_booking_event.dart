part of 'customer_booking_bloc.dart';

sealed class CustomerBookingEvent extends Equatable {
  const CustomerBookingEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerBookings extends CustomerBookingEvent {

  const FetchCustomerBookings({this.status});
  final String? status;

  @override
  List<Object?> get props => [status];
}
