part of 'ratings_bloc.dart';

sealed class RatingsEvent extends Equatable {
  const RatingsEvent();

  @override
  List<Object?> get props => [];
}


class FetchCustomerRatings extends RatingsEvent {}


class FetchProviderRatings extends RatingsEvent {}


class RateProviderEvent extends RatingsEvent {

  const RateProviderEvent({
    required this.serviceRequestId,
    required this.ratings,
    required this.review,
  });
  final String serviceRequestId;
  final int ratings;
  final String review;

  @override
  List<Object?> get props => [serviceRequestId, ratings, review];
}
