part of 'ratings_bloc.dart';

sealed class RatingsState extends Equatable {
  const RatingsState();

  @override
  List<Object?> get props => [];
}

final class RatingsInitial extends RatingsState {}

class RatingsLoading extends RatingsState {}

class RatingsLoaded extends RatingsState {
  const RatingsLoaded({this.customerRatings, this.providerRatings});

  final CustomerRatings? customerRatings;
  final ProviderRatings? providerRatings;

  RatingsLoaded copyWith({
    CustomerRatings? customerRatings,
    ProviderRatings? providerRatings,
  }) {
    return RatingsLoaded(
      customerRatings: customerRatings ?? this.customerRatings,
      providerRatings: providerRatings ?? this.providerRatings,
    );
  }

  @override
  List<Object?> get props => [customerRatings, providerRatings];
}

class RateProviderSuccess extends RatingsState {}

class RatingsError extends RatingsState {
  const RatingsError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
