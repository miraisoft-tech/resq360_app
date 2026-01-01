
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
  }

  Future<void> _onFetch(
    ProviderFetchBookings event,
    Emitter<ProviderServiceState> emit,
  ) async {
    emit(ProviderServicesLoading());
    
 final result = await serviceRepo.getServiceBookings(status: event.status);
    if (result.data != null) {
      emit(ProviderBookingsLoaded(result.data!.data!));
    } else {
      emit(
        ProviderServicesError(
          result.error ?? 'Failed to book service',
        ),
      );
    }
  }
}
