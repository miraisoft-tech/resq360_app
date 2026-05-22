import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/advertisement_repo.dart';
import 'package:resq360/features/customer/dashboard/data/service/payment_repo.dart';

part 'promotion_event.dart';
part 'promotion_state.dart';

final AdvertisementRepo _advertRepo = AdvertisementRepo();
final PaymentRepo _paymentRepo = PaymentRepo();

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  PromotionBloc() : super(PromotionInitial()) {
    on<FetchMyPromotions>(_onFetchMyPromotions);
    on<FetchActivePromotions>(_onFetchActivePromotions);
    on<FetchPromotionPrice>(_onFetchPromotionPrice);

    on<CreatePromotion>(_onCreatePromotion);
    on<VerifyPromotionPayment>(_onVerifyPromotionPayment);

    on<UpdatePromotion>(_onUpdatePromotion);
    on<DeletePromotion>(_onDeletePromotion);
  }

  Future<void> _onFetchMyPromotions(
    FetchMyPromotions event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());

    final providerId = await AuthLocalRepo.instance.getProviderId();
    if (providerId == null) {
      emit(const PromotionError(error: 'Provider not logged in'));
      return;
    }

    final result = await _advertRepo.fetchMyPromotions(providerId: providerId);

    if (result.data != null) {
      emit(PromotionsFetched(promotions: result.data!));
    } else {
      emit(PromotionError(error: result.error ?? 'Failed to fetch promotions'));
    }
  }

  Future<void> _onFetchActivePromotions(
    FetchActivePromotions event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());

    final result = await _advertRepo.fetchProviderActiveAdvertisements(
      providerId: event.providerId,
    );

    if (result.data != null) {
      emit(ActivePromotionsFetched(promotions: result.data!));
    } else {
      emit(PromotionError(error: result.error ?? 'Failed to fetch promotions'));
    }
  }

  Future<void> _onFetchPromotionPrice(
    FetchPromotionPrice event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());

    final result = await _advertRepo.fetchAdvertPrice();

    if (result.data != null) {
      emit(PromotionPriceFetched(price: result.data!));
    } else {
      emit(PromotionError(error: result.error ?? 'Failed to fetch price'));
    }
  }

  Future<void> _onCreatePromotion(
    CreatePromotion event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());

    final result = await _advertRepo.createAdvertisement(
      providerServiceId: event.providerServiceId,
      discountPercentage: event.discountPercentage,
      durationInMilliSeconds: event.durationInMilliSeconds,
      paymentMethod: event.paymentMethod,
      description: event.description,
    );

    if (result.error != null) {
      emit(PromotionError(error: result.error!));
      return;
    }

    final response = result.data!;
    if (response.paymentResponse == null) {
      emit(PromotionCreated());
    } else {
      emit(PromotionPaymentInitiated(response.paymentResponse!));
    }
  }

  Future<void> _onVerifyPromotionPayment(
    VerifyPromotionPayment event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionPaymentVerifying());

    final result = await _paymentRepo.verifyPayment(event.reference);

    if (result.isSuccess && result.data != null) {
      final payment = result.data!;
      if (payment.gatewayResponse == 'Successful' ||
          payment.status == 'success') {
        emit(PromotionCreated());
      } else {
        emit(
          PromotionError(error: 'Payment failed: ${payment.gatewayResponse}'),
        );
      }
    } else {
      emit(
        PromotionError(error: result.error ?? 'Payment verification failed'),
      );
    }
  }

  Future<void> _onUpdatePromotion(
    UpdatePromotion event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());

    final result = await _advertRepo.updateAdvertisement(
      id: event.id,
      title: event.title,
      description: event.description,
      discountPercentage: event.discountPercentage,
    );

    if (result.data != null) {
      emit(PromotionUpdated());
      add(FetchMyPromotions());
    } else {
      emit(PromotionError(error: result.error ?? 'Failed to update promotion'));
    }
  }

  Future<void> _onDeletePromotion(
    DeletePromotion event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());

    final result = await _advertRepo.deleteAdvertisement(event.id);

    if (result.data ?? false) {
      emit(PromotionDeleted());
      add(FetchMyPromotions());
    } else {
      emit(PromotionError(error: result.error ?? 'Failed to delete promotion'));
    }
  }
}
