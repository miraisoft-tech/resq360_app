part of 'provider_ongoing_bloc.dart';

sealed class ProviderOngoingEvent extends Equatable {
  const ProviderOngoingEvent();

  @override
  List<Object> get props => [];
}

class FetchProviderOngoingService extends ProviderOngoingEvent {
  const FetchProviderOngoingService();
}
