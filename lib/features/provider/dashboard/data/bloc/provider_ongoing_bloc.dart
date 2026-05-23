import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'provider_ongoing_event.dart';
part 'provider_ongoing_state.dart';

class ProviderOngoingBloc
    extends Bloc<ProviderOngoingEvent, ProviderOngoingState> {
  ProviderOngoingBloc() : super(ProviderOngoingInitial()) {
    on<FetchProviderOngoingService>(_onFetch);
  }

  final ServiceRepo _repo = ServiceRepo();

  Future<void> _onFetch(
    FetchProviderOngoingService event,
    Emitter<ProviderOngoingState> emit,
  ) async {
    emit(ProviderOngoingLoading());

    try {
      final results = await Future.wait([
        // _repo.getServiceBookings(status: 'completed'),
        _repo.getServiceBookings(status: 'ongoing'),
        _repo.getServiceBookings(status: 'upcoming'),
      ]);

      // final completed = results[0].data ?? [];
      final ongoing = results[0].data ?? [];
      final upcoming = results[1].data ?? [];

      // // Priority 1: completed by customer (provider hasn't confirmed yet)
      // final customerCompleted =
      //     completed.where((b) => b.completedBy == null).toList();
      // if (customerCompleted.isNotEmpty) {
      //   emit(ProviderOngoingLoaded(customerCompleted));
      //   return;
      // }

      // Priority 2: ongoing bookings
      if (ongoing.isNotEmpty) {
        emit(ProviderOngoingLoaded(ongoing));
        return;
      }

      // Priority 3: upcoming bookings
      if (upcoming.isNotEmpty) {
        emit(ProviderOngoingLoaded(upcoming, label: 'Upcoming Service'));
        return;
      }

      emit(const ProviderOngoingLoaded([]));
    } on Exception catch (e) {
      emit(ProviderOngoingError(e.toString()));
    }
  }
}
