import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'customer_booking_event.dart';
part 'customer_booking_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();

class CustomerBookingBloc extends Bloc<CustomerBookingEvent, CustomerBookingState> {
  CustomerBookingBloc() : super(CustomerBookingInitial()) {
    on<FetchCustomerBookings> (_onGetServiceBookings);
  }  

  Future<void> _onGetServiceBookings(
  FetchCustomerBookings event,
  Emitter<CustomerBookingState> emit,
) async {
  emit(CustomerBookingLoading());
  try {
    final result = await serviceRepo.getServiceBookings(
       status: event.status,
    );

    if (result.data != null) {
      emit(CustomerBookingLoaded( result.data!.data ?? []));
    } else {
      emit(CustomerBookingError(
        error: result.error ?? 'Failed to book service',
      ));
    }
  } on Exception catch (e) {
    emit(CustomerBookingError(error: e.toString()));
  }
}

}
