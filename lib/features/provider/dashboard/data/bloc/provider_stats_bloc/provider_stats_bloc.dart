import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_stats.model.dart';
import 'package:resq360/features/provider/authentication/data/service/provider_auth_remote.repo.dart';

part 'provider_stats_event.dart';
part 'provider_stats_state.dart';

class ProviderStatsBloc extends Bloc<ProviderStatsEvent, ProviderStatsState> {
  ProviderStatsBloc({required ProviderAuthRemoteRepo authRepo})
      : _authRepo = authRepo,
        super(ProviderStatsInitial()) {
    on<FetchProviderStats>(_onFetchProviderStats);
  }

  final ProviderAuthRemoteRepo _authRepo;

  Future<void> _onFetchProviderStats(
    FetchProviderStats event,
    Emitter<ProviderStatsState> emit,
  ) async {
    emit(ProviderStatsLoading());

    try {
      final result = await _authRepo.getProviderStats();

      if (result.data != null) {
        emit(ProviderStatsLoaded(result.data!));
      } else {
        emit(ProviderStatsError(result.error ?? 'Failed to fetch stats'));
      }
    } on Exception catch (e) {
      emit(ProviderStatsError(e.toString()));
    }
  }
}
