import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/settings/data/models/customer_ratings_model.dart';
import 'package:resq360/features/settings/data/models/provider_ratings.dart';
import 'package:resq360/features/settings/data/service/ratings_service.dart';

part 'ratings_event.dart';
part 'ratings_state.dart';


class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  RatingsBloc(this._repo) : super(RatingsInitial()) {
    on<FetchCustomerRatings>(_onFetchCustomerRatings);
    on<FetchProviderRatings>(_onFetchProviderRatings);
    on<FetchProviderRatingsById>(_onFetchProviderRatingsById);
    on<RateProviderEvent>(_onRateProvider);
  }

  final RatingsRepo _repo;

  Future<void> _onFetchCustomerRatings(
    FetchCustomerRatings event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());

    final result = await _repo.customerGetRatings();
      final ratings = result.data;

    if (ratings!= null) {
      emit(CustomerRatingsLoaded(ratings));
    } else {
      emit(RatingsError(result.error ?? 'Failed to load customer ratings'));
    }
  }

  Future<void> _onFetchProviderRatings(
    FetchProviderRatings event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());

    final result = await _repo.providerGetRatings();
    final ratings = result.data;

    if (ratings!= null) {
      emit(ProviderRatingsLoaded(ratings));
    } else {
      emit(RatingsError(result.error ?? 'Failed to load provider ratings'));
    }
  }

    Future<void> _onFetchProviderRatingsById(
    FetchProviderRatingsById event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());

    final result = await _repo.providerGetRatingsById(providerId: event.providerId);
    final ratings = result.data;
    if (ratings != null) {
      emit(ProviderRatingsLoaded(ratings));
    } else {
      emit(RatingsError(result.error ?? 'Failed to load provider ratings'));
    }
  }

  Future<void> _onRateProvider(
    RateProviderEvent event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());

    final result = await _repo.rateProvider(
      serviceRequestId: event.serviceRequestId,
      ratings: event.ratings,
      review: event.review,
    );

    if (result.data ?? false) {
      emit(RateProviderSuccess());
    } else {
      emit(RatingsError(result.error ?? 'Failed to submit rating'));
    }
  }
}
