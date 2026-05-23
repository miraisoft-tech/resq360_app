part of 'customer_booking_bloc.dart';

sealed class CustomerBookingState extends Equatable {
  const CustomerBookingState();

  @override
  List<Object?> get props => [];
}

final class CustomerBookingInitial extends CustomerBookingState {}

class CustomerBookingLoading extends CustomerBookingState {}

class CustomerBookingLoaded extends CustomerBookingState {
  const CustomerBookingLoaded(
    this.bookings, {
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });
  final List<Bookings> bookings;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  CustomerBookingLoaded copyWith({
    List<Bookings>? bookings,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return CustomerBookingLoaded(
      bookings ?? this.bookings,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props => [bookings, currentPage, hasMore, isLoadingMore];
}

class DashboardBookingLoaded extends CustomerBookingState {
  const DashboardBookingLoaded({this.booking, this.label = 'Ongoing Service'});
  final Bookings? booking;
  final String label;

  @override
  List<Object?> get props => [booking, label];
}

class CustomerBookingError extends CustomerBookingState {
  const CustomerBookingError({required this.error});
  final String error;
}
