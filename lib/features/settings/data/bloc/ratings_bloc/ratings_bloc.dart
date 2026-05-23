import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/settings/data/models/customer_ratings_model.dart';
import 'package:resq360/features/settings/data/models/provider_ratings.dart';
import 'package:resq360/features/settings/data/service/ratings_service.dart';

part 'ratings_event.dart';
part 'ratings_state.dart';

class RatingsBloc extends Bloc<RatingsEvent, RatingsState> {
  RatingsBloc(this._repo) : super(const RatingsLoaded()) {
    on<FetchCustomerRatings>(_onFetchCustomerRatings);
    on<LoadMoreCustomerRatings>(_onLoadMoreCustomerRatings);
    on<FetchProviderRatings>(_onFetchProviderRatings);
    on<LoadMoreProviderRatings>(_onLoadMoreProviderRatings);
    on<FetchProviderRatingsById>(_onFetchProviderRatingsById);
    on<FetchCustomerRatingsById>(_onFetchCustomerRatingsById);
    on<RateProviderEvent>(_onRateProvider);
  }

  final RatingsRepo _repo;

  RatingsLoaded get _current =>
      state is RatingsLoaded ? state as RatingsLoaded : const RatingsLoaded();

  Future<void> _onFetchCustomerRatings(
    FetchCustomerRatings event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());
    final result = await _repo.customerGetRatings(
      page: event.page,
      limit: event.limit,
    );
    final ratings = result.data;

    if (ratings != null) {
      emit(
        _current.copyWith(
          customerRatings: ratings,
          customerRatingsCurrentPage: result.meta?.currentPage ?? event.page,
          customerRatingsHasMore: result.meta?.hasMore ?? false,
          customerRatingsLoadingMore: false,
        ),
      );
    } else {
      emit(RatingsError(result.error ?? 'Failed to load customer ratings'));
    }
  }

  Future<void> _onLoadMoreCustomerRatings(
    LoadMoreCustomerRatings event,
    Emitter<RatingsState> emit,
  ) async {
    final current = _current;
    if (!current.customerRatingsHasMore || current.customerRatingsLoadingMore) {
      return;
    }

    emit(current.copyWith(customerRatingsLoadingMore: true));

    final nextPage = current.customerRatingsCurrentPage + 1;
    final result = await _repo.customerGetRatings(
      page: nextPage,
      limit: event.limit,
    );
    final ratings = result.data;

    if (ratings != null) {
      emit(
        current.copyWith(
          customerRatings: _appendCustomerRatings(
            current.customerRatings,
            ratings,
          ),
          customerRatingsCurrentPage: result.meta?.currentPage ?? nextPage,
          customerRatingsHasMore: result.meta?.hasMore ?? false,
          customerRatingsLoadingMore: false,
        ),
      );
    } else {
      emit(current.copyWith(customerRatingsLoadingMore: false));
    }
  }

  Future<void> _onFetchProviderRatings(
    FetchProviderRatings event,
    Emitter<RatingsState> emit,
  ) async {
    emit(RatingsLoading());
    final result = await _repo.providerGetRatings(
      page: event.page,
      limit: event.limit,
    );
    final ratings = result.data;

    if (ratings != null) {
      emit(
        _current.copyWith(
          providerRatings: ratings,
          providerRatingsCurrentPage: result.meta?.currentPage ?? event.page,
          providerRatingsHasMore: result.meta?.hasMore ?? false,
          providerRatingsLoadingMore: false,
        ),
      );
    } else {
      emit(RatingsError(result.error ?? 'Failed to load provider ratings'));
    }
  }

  Future<void> _onLoadMoreProviderRatings(
    LoadMoreProviderRatings event,
    Emitter<RatingsState> emit,
  ) async {
    final current = _current;
    if (!current.providerRatingsHasMore || current.providerRatingsLoadingMore) {
      return;
    }

    emit(current.copyWith(providerRatingsLoadingMore: true));

    final nextPage = current.providerRatingsCurrentPage + 1;
    final result = await _repo.providerGetRatings(
      page: nextPage,
      limit: event.limit,
    );
    final ratings = result.data;

    if (ratings != null) {
      emit(
        current.copyWith(
          providerRatings: _appendProviderRatings(
            current.providerRatings,
            ratings,
          ),
          providerRatingsCurrentPage: result.meta?.currentPage ?? nextPage,
          providerRatingsHasMore: result.meta?.hasMore ?? false,
          providerRatingsLoadingMore: false,
        ),
      );
    } else {
      emit(current.copyWith(providerRatingsLoadingMore: false));
    }
  }

  Future<void> _onFetchProviderRatingsById(
    FetchProviderRatingsById event,
    Emitter<RatingsState> emit,
  ) async {
    final result = await _repo.providerGetRatingsById(
      providerId: event.providerId,
    );
    final ratings = result.data;

    if (ratings != null) {
      emit(_current.copyWith(providerRatings: ratings));
    } else {
      emit(RatingsError(result.error ?? 'Failed to load provider ratings'));
    }
  }

  Future<void> _onFetchCustomerRatingsById(
    FetchCustomerRatingsById event,
    Emitter<RatingsState> emit,
  ) async {
    final result = await _repo.customerGetRatingsById(userId: event.userId);
    final ratings = result.data;

    if (ratings != null) {
      emit(_current.copyWith(customerRatings: ratings));
    } else {
      emit(RatingsError(result.error ?? 'Failed to load customer ratings'));
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

  CustomerRatings _appendCustomerRatings(
    CustomerRatings? current,
    CustomerRatings next,
  ) {
    return CustomerRatings(
      averageRatings: next.averageRatings ?? current?.averageRatings,
      totalReviews: next.totalReviews ?? current?.totalReviews,
      reviews: [
        ...(current?.reviews ?? const <CustomerReview>[]),
        ...(next.reviews ?? const <CustomerReview>[]),
      ],
    );
  }

  ProviderRatings _appendProviderRatings(
    ProviderRatings? current,
    ProviderRatings next,
  ) {
    return ProviderRatings(
      averageRatings: next.averageRatings ?? current?.averageRatings,
      totalReviews: next.totalReviews ?? current?.totalReviews,
      reviews: [
        ...(current?.reviews ?? const <ProviderReview>[]),
        ...(next.reviews ?? const <ProviderReview>[]),
      ],
    );
  }
}
