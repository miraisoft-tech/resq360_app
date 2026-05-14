part of 'provider_stats_bloc.dart';

sealed class ProviderStatsEvent extends Equatable {
  const ProviderStatsEvent();

  @override
  List<Object> get props => [];
}

class FetchProviderStats extends ProviderStatsEvent {
  const FetchProviderStats();

  @override
  List<Object> get props => [];
}
