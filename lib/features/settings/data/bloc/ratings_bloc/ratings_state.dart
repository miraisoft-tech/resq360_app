part of 'ratings_bloc.dart';

sealed class RatingsState extends Equatable {
  const RatingsState();

  @override
  List<Object?> get props => [];
}

final class RatingsInitial extends RatingsState {}

class RatingsLoading extends RatingsState {}

class RatingsLoaded extends RatingsState {
  const RatingsLoaded({
    this.customerRatings,
    this.providerRatings,
    this.customerRatingsCurrentPage = 1,
    this.customerRatingsHasMore = false,
    this.customerRatingsLoadingMore = false,
    this.providerRatingsCurrentPage = 1,
    this.providerRatingsHasMore = false,
    this.providerRatingsLoadingMore = false,
  });

  final CustomerRatings? customerRatings;
  final ProviderRatings? providerRatings;
  final int customerRatingsCurrentPage;
  final bool customerRatingsHasMore;
  final bool customerRatingsLoadingMore;
  final int providerRatingsCurrentPage;
  final bool providerRatingsHasMore;
  final bool providerRatingsLoadingMore;

  RatingsLoaded copyWith({
    CustomerRatings? customerRatings,
    ProviderRatings? providerRatings,
    int? customerRatingsCurrentPage,
    bool? customerRatingsHasMore,
    bool? customerRatingsLoadingMore,
    int? providerRatingsCurrentPage,
    bool? providerRatingsHasMore,
    bool? providerRatingsLoadingMore,
  }) {
    return RatingsLoaded(
      customerRatings: customerRatings ?? this.customerRatings,
      providerRatings: providerRatings ?? this.providerRatings,
      customerRatingsCurrentPage:
          customerRatingsCurrentPage ?? this.customerRatingsCurrentPage,
      customerRatingsHasMore:
          customerRatingsHasMore ?? this.customerRatingsHasMore,
      customerRatingsLoadingMore:
          customerRatingsLoadingMore ?? this.customerRatingsLoadingMore,
      providerRatingsCurrentPage:
          providerRatingsCurrentPage ?? this.providerRatingsCurrentPage,
      providerRatingsHasMore:
          providerRatingsHasMore ?? this.providerRatingsHasMore,
      providerRatingsLoadingMore:
          providerRatingsLoadingMore ?? this.providerRatingsLoadingMore,
    );
  }

  @override
  List<Object?> get props => [
    customerRatings,
    providerRatings,
    customerRatingsCurrentPage,
    customerRatingsHasMore,
    customerRatingsLoadingMore,
    providerRatingsCurrentPage,
    providerRatingsHasMore,
    providerRatingsLoadingMore,
  ];
}

class RateProviderSuccess extends RatingsState {}

class RatingsError extends RatingsState {
  const RatingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
