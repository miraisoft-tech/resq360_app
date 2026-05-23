part of 'ratings_bloc.dart';

sealed class RatingsEvent extends Equatable {
  const RatingsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCustomerRatings extends RatingsEvent {
  const FetchCustomerRatings({this.page = 1, this.limit = 20});

  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}

class LoadMoreCustomerRatings extends RatingsEvent {
  const LoadMoreCustomerRatings({this.limit = 20});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class FetchCustomerRatingsById extends RatingsEvent {
  const FetchCustomerRatingsById({required this.userId});

  final int userId;

  @override
  List<Object?> get props => [userId];
}

class FetchProviderRatings extends RatingsEvent {
  const FetchProviderRatings({this.page = 1, this.limit = 20});

  final int page;
  final int limit;

  @override
  List<Object?> get props => [page, limit];
}

class LoadMoreProviderRatings extends RatingsEvent {
  const LoadMoreProviderRatings({this.limit = 20});

  final int limit;

  @override
  List<Object?> get props => [limit];
}

class FetchProviderRatingsById extends RatingsEvent {
  const FetchProviderRatingsById({required this.providerId});

  final int providerId;

  @override
  List<Object?> get props => [providerId];
}

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
