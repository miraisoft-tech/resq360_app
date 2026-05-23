import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc({required this.serviceRepo}) : super(BookingInitial()) {
    on<StartBooking>(_onStartBooking);
    on<ArriveBooking>(_onArriveBooking);
    on<CancelBooking>(_onCancelBooking);
    on<CompleteBooking>(_onCompleteBooking);
  }
  final ServiceRepo serviceRepo;

  Future<void> _onStartBooking(
    StartBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await serviceRepo.startServiceBooking(
        event.serviceRequestId,
      );

      if (result.error != null) {
        emit(BookingError(error: result.error ?? 'Failed to start booking'));
      } else {
        emit(BookingStarted(serviceRequestId: event.serviceRequestId));
      }
    } on Exception catch (e) {
      emit(BookingError(error: e.toString()));
    }
  }

  Future<void> _onArriveBooking(
    ArriveBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await serviceRepo.arriveServiceBooking(
        event.serviceRequestId,
      );

      if (result.error != null) {
        emit(
          BookingError(
            error: result.error ?? 'Failed to mark provider arrived',
          ),
        );
      } else {
        emit(BookingArrived(serviceRequestId: event.serviceRequestId));
      }
    } on Exception catch (e) {
      emit(BookingError(error: e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await serviceRepo.cancelServiceBooking(
        serviceRequestId: event.serviceRequestId,
        cancellationReason: event.cancellationReason,
      );

      log(result);
      if (result.error != null) {
        emit(BookingError(error: result.error ?? 'Failed to cancel booking'));
      } else {
        emit(BookingCancelled(serviceRequestId: event.serviceRequestId));
      }
    } on Exception catch (e) {
      emit(BookingError(error: e.toString()));
    }
  }

  Future<void> _onCompleteBooking(
    CompleteBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(BookingLoading());
    try {
      final result = await serviceRepo.completeServiceBooking(
        event.serviceRequestId,
        ratings: event.ratings,
        review: event.review,
      );

      if (result.error != null) {
        emit(BookingError(error: result.error ?? 'Failed to complete booking'));
      } else {
        emit(BookingCompleted(serviceRequestId: event.serviceRequestId));
      }
    } on Exception catch (e) {
      emit(BookingError(error: e.toString()));
    }
  }
}
