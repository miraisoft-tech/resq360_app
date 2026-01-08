part of 'booking_bloc.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}


class StartBooking extends BookingEvent {

  const StartBooking({required this.serviceRequestId});
  final int serviceRequestId;

  @override
  List<Object?> get props => [serviceRequestId];
}

class CancelBooking extends BookingEvent {

  const CancelBooking({
    required this.serviceRequestId,
    required this.cancellationReason,
  });
  final int serviceRequestId;
  final String cancellationReason;

  @override
  List<Object?> get props => [serviceRequestId, cancellationReason];
}

class CompleteBooking extends BookingEvent {

  const CompleteBooking({
    required this.serviceRequestId,
    required this.ratings,
    required this.review,
  });
  final int serviceRequestId;
  final double ratings;
  final String review;

  @override
  List<Object?> get props => [serviceRequestId, ratings, review];
}
