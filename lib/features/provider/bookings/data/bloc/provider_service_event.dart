part of 'provider_service_bloc.dart';

sealed class ProviderServiceEvent extends Equatable {
  const ProviderServiceEvent();

  @override
  List<Object> get props => [];
}

class ProviderFetchBookings extends ProviderServiceEvent {
  const ProviderFetchBookings({this.status});
  final String? status;
}

class LoadMoreProviderBookings extends ProviderServiceEvent {
  const LoadMoreProviderBookings({required this.status});
  final String status;
}

class ProviderStartServiceBooking extends ProviderServiceEvent {
  const ProviderStartServiceBooking(this.serviceRequestId);
  final int serviceRequestId;
}

class ProviderArriveServiceBooking extends ProviderServiceEvent {
  const ProviderArriveServiceBooking(this.serviceRequestId);
  final int serviceRequestId;
}

class ProviderCancelServiceBooking extends ProviderServiceEvent {
  const ProviderCancelServiceBooking({
    required this.serviceRequestId,
    required this.cancellationReason,
  });
  final int serviceRequestId;
  final String cancellationReason;
}

class ProviderCompleteServiceBooking extends ProviderServiceEvent {
  const ProviderCompleteServiceBooking({
    required this.serviceRequestId,
    required this.ratings,
    required this.review,
  });
  final int serviceRequestId;
  final int ratings;
  final String review;
}
