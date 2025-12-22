part of 'ratings_bloc.dart';

sealed class RatingsState extends Equatable {
  const RatingsState();
  
  @override
  List<Object?> get props => [];
}

final class RatingsInitial extends RatingsState {}

class RatingsLoading extends RatingsState {}

class CustomerRatingsLoaded extends RatingsState {

  const CustomerRatingsLoaded(this.ratings);
  final CustomerRatings ratings;

  @override
  List<Object?> get props => [ratings];
}

class ProviderRatingsLoaded extends RatingsState {

  const ProviderRatingsLoaded(this.ratings);
  final ProviderRatings ratings;

  @override
  List<Object?> get props => [ratings];
}

class RateProviderSuccess extends RatingsState {}

class RatingsError extends RatingsState {

  const RatingsError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
