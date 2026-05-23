part of 'provider_bloc.dart';

abstract class ProviderEvent extends Equatable {
  const ProviderEvent();

  @override
  List<Object?> get props => [];
}

class FetchAServiceProvider extends ProviderEvent {

  const FetchAServiceProvider({required this.providerId});
  final int providerId;

  @override
  List<Object?> get props => [providerId];
}
