part of 'provider_service_bloc.dart';

sealed class ProviderServiceState extends Equatable {
  const ProviderServiceState();

  @override
  List<Object> get props => [];
}

final class ProviderServiceInitial extends ProviderServiceState {}

class ProviderServicesInitial extends ProviderServiceState {}

class ProviderServicesLoading extends ProviderServiceState {}

class ProviderBookingsLoaded extends ProviderServiceState {
  const ProviderBookingsLoaded(
    this.bookings, {
    this.currentPage = 1,
    this.hasMore = false,
    this.isLoadingMore = false,
  });
  final List<Bookings> bookings;
  final int currentPage;
  final bool hasMore;
  final bool isLoadingMore;

  ProviderBookingsLoaded copyWith({
    List<Bookings>? bookings,
    int? currentPage,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return ProviderBookingsLoaded(
      bookings ?? this.bookings,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class ProviderServicesError extends ProviderServiceState {
  const ProviderServicesError({required this.error});
  final String error;
}

class ProviderServiceBookingStarted extends ProviderServiceState {}

class ProviderServiceBookingArrived extends ProviderServiceState {}

class ProviderServiceBookingCompleted extends ProviderServiceState {}

class ProviderServiceBookingCancelled extends ProviderServiceState {}
