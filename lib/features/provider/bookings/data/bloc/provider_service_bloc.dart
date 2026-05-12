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
      emit(ProviderBookingsLoaded(result.data!));
    } else {
      emit(
        ProviderServicesError(error: result.error ?? 'Failed to book service'),
      );
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

  Future<void> _onStartBooking(
    ProviderStartServiceBooking event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());
    try {
      final result = await serviceRepo.startServiceBooking(
        event.serviceRequestId,
      );

      if (!result.isSuccess) {
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
