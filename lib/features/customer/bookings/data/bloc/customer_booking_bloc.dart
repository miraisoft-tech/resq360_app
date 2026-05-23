import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/bookings/booking.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';

part 'customer_booking_event.dart';
part 'customer_booking_state.dart';

final ServiceRepo serviceRepo = ServiceRepo();

class CustomerBookingBloc
    extends Bloc<CustomerBookingEvent, CustomerBookingState> {
  CustomerBookingBloc() : super(CustomerBookingInitial()) {
    on<FetchCustomerBookings>(_onGetServiceBookings);
    on<LoadMoreCustomerBookings>(_onLoadMore);
    on<FetchDashboardBookings>(_onFetchDashboardBookings);
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
        final hasMore = result.meta?.hasMore ?? false;
        final currentPage = result.meta?.currentPage ?? 1;
        emit(
          CustomerBookingLoaded(
            bookings,
            currentPage: currentPage,
            hasMore: hasMore,
          ),
        );
      } else {
        emit(
          CustomerBookingError(error: result.error ?? 'Failed to book service'),
        );
      }
    } on Exception catch (e) {
      emit(CustomerBookingError(error: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    LoadMoreCustomerBookings event,
    Emitter<CustomerBookingState> emit,
  ) async {
    final current = state;
    if (current is! CustomerBookingLoaded) return;
    if (current.isLoadingMore || !current.hasMore) return;

    emit(current.copyWith(isLoadingMore: true));

    try {
      final nextPage = current.currentPage + 1;
      final result = await serviceRepo.getServiceBookings(
        status: event.status,
        page: nextPage,
      );

      if (result.data != null) {
        final newBookings = result.data ?? [];
        final allBookings = [...current.bookings, ...newBookings];
        final sorted = _sortBookings(allBookings, event.status);
        final hasMore = result.meta?.hasMore ?? false;
        final currentPage = result.meta?.currentPage ?? nextPage;
        emit(
          CustomerBookingLoaded(
            sorted,
            currentPage: currentPage,
            hasMore: hasMore,
          ),
        );
      } else {
        emit(current.copyWith(isLoadingMore: false));
      }
    } on Exception {
      emit(current.copyWith(isLoadingMore: false));
    }
  }

  Future<void> _onFetchDashboardBookings(
    FetchDashboardBookings event,
    Emitter<CustomerBookingState> emit,
  ) async {
    emit(CustomerBookingLoading());
    try {
      final results = await Future.wait([
        serviceRepo.getServiceBookings(status: 'completed'),
        serviceRepo.getServiceBookings(status: 'ongoing'),
        serviceRepo.getServiceBookings(status: 'upcoming'),
      ]);

      final completed = results[0].data ?? [];
      final ongoing = results[1].data ?? [];
      final upcoming = results[2].data ?? [];

      // Priority 1: completed by provider (customer hasn't confirmed yet)
      final providerCompleted =
          completed
              .where(
                (b) => b.completedBy == UserType.provider.value.toUpperCase(),
              )
              .toList();
      if (providerCompleted.isNotEmpty) {
        emit(DashboardBookingLoaded(booking: providerCompleted.first));
        return;
      }

      // Priority 2: ongoing bookings
      if (ongoing.isNotEmpty) {
        emit(DashboardBookingLoaded(booking: ongoing.first));
        return;
      }

      // Priority 3: upcoming bookings
      if (upcoming.isNotEmpty) {
        emit(
          DashboardBookingLoaded(
            booking: upcoming.first,
            label: 'Current Service',
          ),
        );
        return;
      }

      emit(const DashboardBookingLoaded());
    } on Exception catch (e) {
      emit(CustomerBookingError(error: e.toString()));
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
}
