part of 'booking_bloc.dart';

sealed class BookingState extends Equatable {
  const BookingState();
  
  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {}

class BookingLoading extends BookingState {}

class BookingStarted extends BookingState {

  const BookingStarted({required this.serviceRequestId});
  final int serviceRequestId;

  @override
  List<Object?> get props => [serviceRequestId];
}

class BookingCancelled extends BookingState {

  const BookingCancelled({required this.serviceRequestId});
  final int serviceRequestId;

  @override
  List<Object?> get props => [serviceRequestId];
}

class BookingCompleted extends BookingState {

  const BookingCompleted({required this.serviceRequestId});
  final int serviceRequestId;

  @override
  List<Object?> get props => [serviceRequestId];
}

class BookingError extends BookingState {

  const BookingError({required this.error});
  final String error;

  @override
  List<Object?> get props => [error];
}
