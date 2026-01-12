import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/dashboard/data/models/service-model/service.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/service_repo.dart';

part 'provider_event.dart';
part 'provider_state.dart';

class ProviderBloc extends Bloc<ProviderEvent, ProviderState> {
  
  ProviderBloc({ServiceRepo? serviceRepo}) 
      : _serviceRepo = serviceRepo ?? ServiceRepo(),
        super(ProviderInitial()) {
    on<FetchAServiceProvider>(_onFetchProvider);
  }
  final ServiceRepo _serviceRepo;

  Future<void> _onFetchProvider(
    FetchAServiceProvider event,
    Emitter<ProviderState> emit,
  ) async {
    emit(ProviderLoading());
    try {
      final result = await _serviceRepo.fetchProviderByid(
        providerId: event.providerId,
      );
      
      if (result.data != null) {
        emit(ProviderLoaded(provider: result.data!));
      } else {
        emit(
          ProviderError(
            error: result.error ?? 'Failed to load provider',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ProviderError(error: e.toString()));
    }
  }
}
