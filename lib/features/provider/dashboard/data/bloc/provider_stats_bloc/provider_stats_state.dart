part of 'provider_stats_bloc.dart';

sealed class ProviderStatsState extends Equatable {
  const ProviderStatsState();

  @override
  List<Object> get props => [];
}

final class ProviderStatsInitial extends ProviderStatsState {}

class ProviderStatsLoading extends ProviderStatsState {}

class ProviderStatsLoaded extends ProviderStatsState {
  const ProviderStatsLoaded(this.stats);
  final ProviderStats stats;

  @override
  List<Object> get props => [stats];
}

class ProviderStatsError extends ProviderStatsState {
  const ProviderStatsError(this.error);
  final String error;

  @override
  List<Object> get props => [error];
}
