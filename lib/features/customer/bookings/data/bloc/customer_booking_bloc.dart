import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'customer_booking_event.dart';
part 'customer_booking_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();

class CustomerBookingBloc
    extends Bloc<CustomerBookingEvent, CustomerBookingState> {
  CustomerBookingBloc() : super(CustomerBookingInitial()) {
    on<FetchCustomerBookings>(_onGetServiceBookings);
  }

  Future<void> _onGetServiceBookings(
    FetchCustomerBookings event,
    Emitter<CustomerBookingState> emit,
  ) async {
    emit(CustomerBookingLoading());
    try {
      final result = await serviceRepo.getServiceBookings(status: event.status);

      if (result.data != null) {
        final bookings = _sortBookings(result.data ?? [], event.status);
        emit(CustomerBookingLoaded(bookings));
      } else {
        emit(
          CustomerBookingError(error: result.error ?? 'Failed to book service'),
        );
      }
    } on Exception catch (e) {
      emit(CustomerBookingError(error: e.toString()));
    }
  }

  List<Bookings> _sortBookings(List<Bookings> bookings, String? status) {
    return bookings
      ..sort((a, b) {
        final aDate = _bookingSortDate(a, status);
        final bDate = _bookingSortDate(b, status);
        return bDate.compareTo(aDate);
      });
  }

  DateTime _bookingSortDate(Bookings booking, String? status) {
    switch (status) {
      case 'completed':
        return booking.completedAt ?? booking.updatedAt ?? booking.createdAt ?? DateTime(0);
      case 'ongoing':
        return booking.providerStartedAt ?? booking.expectedStartDate ?? booking.updatedAt ?? booking.createdAt ?? DateTime(0);
      case 'cancelled':
        return booking.updatedAt ?? booking.createdAt ?? DateTime(0);
      default:
        return booking.createdAt ?? booking.expectedStartDate ?? booking.updatedAt ?? DateTime(0);
    }
  }
}
