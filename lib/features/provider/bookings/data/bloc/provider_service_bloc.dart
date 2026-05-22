import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'provider_service_event.dart';
part 'provider_service_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();

class ProviderServiceBloc
    extends Bloc<ProviderServiceEvent, ProviderServiceState> {
  ProviderServiceBloc() : super(ProviderServiceInitial()) {
    on<ProviderFetchBookings>(_onFetch);
    on<ProviderArriveServiceBooking>(_onArriveBooking);
    on<ProviderStartServiceBooking>(_onStartBooking);

    on<ProviderCompleteServiceBooking>(_onCompleteBooking);
    on<ProviderCancelServiceBooking>(_onCancelBooking);
  }

  Future<void> _onFetch(
    ProviderFetchBookings event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());

    final result = await serviceRepo.getServiceBookings(status: event.status);
    if (result.data != null) {
      final bookings = _sortBookings(result.data ?? [], event.status);
      emit(ProviderBookingsLoaded(bookings));
    } else {
      emit(
        ProviderServicesError(error: result.error ?? 'Failed to book service'),
      );
    }
  }

  List<Bookings> _sortBookings(List<Bookings> bookings, String? status) {
    return bookings..sort((a, b) {
      final aDate = _bookingSortDate(a, status);
      final bDate = _bookingSortDate(b, status);
      return bDate.compareTo(aDate);
    });
  }

  DateTime _bookingSortDate(Bookings booking, String? status) {
    switch (status) {
      case 'completed':
        return booking.completedAt ??
            booking.updatedAt ??
            booking.createdAt ??
            DateTime(0);
      case 'ongoing':
        return booking.providerStartedAt ??
            booking.expectedStartDate ??
            booking.updatedAt ??
            booking.createdAt ??
            DateTime(0);
      case 'cancelled':
        return booking.updatedAt ?? booking.createdAt ?? DateTime(0);
      default:
        return booking.createdAt ??
            booking.expectedStartDate ??
            booking.updatedAt ??
            DateTime(0);
    }
  }

  Future<void> _onCancelBooking(
    ProviderCancelServiceBooking event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());
    try {
      final result = await serviceRepo.cancelServiceBooking(
        serviceRequestId: event.serviceRequestId,
        cancellationReason: event.cancellationReason,
      );

      if (!result.isSuccess) {
        emit(
          ProviderServicesError(
            error: result.error ?? 'Failed to cancel booking',
          ),
        );
      } else {
        emit(ProviderServiceBookingCancelled());
      }
    } on Exception catch (e) {
      emit(ProviderServicesError(error: e.toString()));
    }
  }

  Future<void> _onArriveBooking(
    ProviderArriveServiceBooking event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());
    try {
      final result = await serviceRepo.arriveServiceBooking(
        event.serviceRequestId,
      );

      if (result.error != null) {
        emit(
          ProviderServicesError(
            error: result.error ?? 'Failed to mark provider arrived',
          ),
        );
      } else {
        emit(ProviderServiceBookingArrived());
      }
    } on Exception catch (e) {
      emit(ProviderServicesError(error: e.toString()));
    }
  }

  Future<void> _onStartBooking(
    ProviderStartServiceBooking event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());
    try {
      final result = await serviceRepo.startServiceBooking(
        event.serviceRequestId,
      );

      if (result.error != null) {
        emit(
          ProviderServicesError(
            error: result.error ?? 'Failed to start service',
          ),
        );
      } else {
        emit(ProviderServiceBookingStarted());
      }
    } on Exception catch (e) {
      emit(ProviderServicesError(error: e.toString()));
    }
  }

  Future<void> _onCompleteBooking(
    ProviderCompleteServiceBooking event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());
    try {
      final result = await serviceRepo.completeServiceBooking(
        event.serviceRequestId,
        ratings: event.ratings,
        review: event.review,
      );

      if (result.error?.isNotEmpty ?? false) {
        emit(
          ProviderServicesError(
            error: result.error ?? 'Failed to complete booking',
          ),
        );
      } else {
        emit(ProviderServiceBookingCompleted());
      }
    } on Exception catch (e) {
      emit(ProviderServicesError(error: e.toString()));
    }
  }
}
