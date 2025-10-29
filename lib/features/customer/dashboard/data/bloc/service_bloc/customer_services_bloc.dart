import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/bookings/data/models/booking_model.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'customer_services_event.dart';
part 'customer_services_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();

class CustomerServicesBloc
    extends Bloc<CustomerServicesEvent, CustomerServicesState> {
  CustomerServicesBloc() : super(CustomerServicesInitial()) {
    on<CustomerFetchServices>(_onFetchCustomerServices);
    on<CustomerFetchProviders>(_onFetchProviders);
    on<CustomerFetchServiceInfo>(_onFetchServiceInfo);
    on<CustomerCreateService>(_onCreateCustomerService);
    // on<CustomerFetchBookings>(_onFetchBookings);
    on<CustomerFetchBookings>(_onGetServiceBookings);
    on<CustomerStartServiceBooking>(_onStartBooking);
    on<CustomerCancelServiceBooking>(_onCancelBooking);
    on<CustomerCompleteServiceBooking>(_onCompleteBooking);
  }

  final ServiceRepo serviceRepo = ServiceRepo();

  Future<void> _onFetchCustomerServices(
    CustomerFetchServices event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.fetchServices();
      if (result.data != null) {
        emit(CustomerServicesLoaded(services: result.data!));
      } else {
        emit(
          CustomerServicesError(
            error: result.error ?? 'Failed to load services',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

  Future<void> _onFetchProviders(
    CustomerFetchProviders event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.fetchProviders(
        serviceCategoryId: event.categoryId,
        activityStatus: event.activityStatus,
        search: event.search,
        nearYou: event.nearYou,
      );
      if (result.data != null) {
        emit(CustomerProvidersLoaded(providers: result.data!));
      } else {
        emit(
          CustomerServicesError(
            error: result.error ?? 'Failed to load providers',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

  Future<void> _onFetchServiceInfo(
    CustomerFetchServiceInfo event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.fetchServiceInfo(event.categoryId);
      if (result.data != null) {
        emit(CustomerServiceInfoLoaded(info: result.data!));
      } else {
        emit(
          CustomerServicesError(
            error: result.error ?? 'Failed to fetch service info',
          ),
        );
      }
    } catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

  Future<void> _onCreateCustomerService(
    CustomerCreateService event,
    Emitter<CustomerServicesState> emit,
  ) async {
    emit(CustomerServicesLoading());
    try {
      final result = await serviceRepo.createService(
        name: event.name,
        description: event.description,
        imagePath: event.imagePath,
      );
      if (result.data != null) {
        emit(CustomerServiceCreated(service: result.data!));
      } else {
        emit(
          CustomerServicesError(
            error: result.error ?? 'Failed to create service',
          ),
        );
      }
    } catch (e) {
      emit(CustomerServicesError(error: e.toString()));
    }
  }

//   Future<void> _onFetchBookings(
//   CustomerFetchBookings event,
//   Emitter<CustomerServicesState> emit,
// ) async {
//   emit(CustomerServicesLoading());
//   final result = await serviceRepo.bookService(status: event.status);

//   if (result.data != null) {
//     emit(CustomerBookingsLoaded(
//       bookings: [result.data!],
//       status: event.status,
//     ));
//   } else {
//     emit(CustomerServicesError(result.error ?? 'Failed to fetch bookings'));
//   }
// }

Future<void> _onGetServiceBookings(
  CustomerFetchBookings event,
  Emitter<CustomerServicesState> emit,
) async {
  emit(CustomerServicesLoading());
  try {
    final result = await serviceRepo.getServiceBookings(
       status: event.status,
    );

    if (result.data != null) {
      emit(CustomerBookingsLoaded( result.data!.data ?? []));
    } else {
      emit(CustomerServicesError(
        error: result.error ?? 'Failed to book service',
      ));
    }
  } on Exception catch (e) {
    emit(CustomerServicesError(error: e.toString()));
  }
}


Future<void> _onStartBooking(
  CustomerStartServiceBooking event,
  Emitter<CustomerServicesState> emit,
) async {
  emit(CustomerServicesLoading());
  try {
    final result = await serviceRepo.startServiceBooking(event.serviceRequestId);

    if (result.error != null) {
      emit(CustomerServicesError(
        error: result.error ?? 'Failed to start booking',
      ));
    } else {
      emit(ServiceBookingStarted());
    }
  } catch (e) {
    emit(CustomerServicesError(error: e.toString()));
  }
}

Future<void> _onCancelBooking(
  CustomerCancelServiceBooking event,
  Emitter<CustomerServicesState> emit,
) async {
  emit(CustomerServicesLoading());
  try {
    final result = await serviceRepo.cancelServiceBooking(event.serviceRequestId);

    if (!result.isSuccess) {
      emit(CustomerServicesError(
        error: result.error ?? 'Failed to cancel booking',
      ));
    } else {
      emit(ServiceBookingCancelled());
    }
  } catch (e) {
    emit(CustomerServicesError(error: e.toString()));
  }
}

Future<void> _onCompleteBooking(
  CustomerCompleteServiceBooking event,
  Emitter<CustomerServicesState> emit,
) async {
  emit(CustomerServicesLoading());
  try {
    final result = await serviceRepo.completeServiceBooking(
      event.serviceRequestId,
      ratings: event.ratings,
      review: event.review,
    );

    if (!result.isSuccess) {
      emit(CustomerServicesError(
        error: result.error ?? 'Failed to complete booking',
      ));
    } else {
      emit(ServiceBookingCompleted());
    }
  } catch (e) {
    emit(CustomerServicesError(error: e.toString()));
  }
}

}
