
import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/advertisment/advertisement.model.dart';
import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/advertisement_repo.dart';
import 'package:resq360/features/customer/dashboard/data/service/payment_repo.dart';

part 'customer_advertisement_event.dart';
part 'customer_advertisement_state.dart';

final AdvertisementRepo advertisementRepo = AdvertisementRepo();
final PaymentRepo paymentRepo = PaymentRepo();

class CustomerAdvertisementBloc
    extends Bloc<CustomerAdvertisementEvent, CustomerAdvertisementState> {
  CustomerAdvertisementBloc() : super(CustomerAdvertisementInitial()) {
    on<CustomerFetchAdvertisement>(_fetchAdvertisement);
    on<CreateAdvertisement>(_onCreateAdvertisement);
    on<FetchAdvertisementPrice>(_onGetAdvertPrice);
    on<VerifyAdvertisementPayment>(_onVerifyAdvertisementPayment);
    on<FetchProviderActiveAdvertisements>(_fetchProviderActiveAdvertisements);
  }

  Future<void> _fetchAdvertisement(
    CustomerFetchAdvertisement event,
    Emitter<CustomerAdvertisementState> emit,
  ) async {
    try {
      final result = await advertisementRepo.fetchAllAdvertisement();
      if (result.data != null) {
        emit(CustomerAdvertisementFetched(adverisementList: result.data!));
      } else {
        emit(CustomerAdvertisementError(error: result.error!));
      }
    } on Exception catch (e) {
      emit(CustomerAdvertisementError(error: e.toString()));
    }
  }

  Future<void> _fetchProviderActiveAdvertisements(
  FetchProviderActiveAdvertisements event,
  Emitter<CustomerAdvertisementState> emit,
) async {
  emit(CustomerAdvertisementLoading());
  
  try {
    final result = await advertisementRepo.fetchProviderActiveAdvertisements(
      providerId: event.providerId,
    );
    
    if (result.data != null) {
      emit(ProviderActiveAdvertisementsFetched(advertisements: result.data!));
    } else {
      emit(CustomerAdvertisementError(error: result.error ?? 'Failed to fetch advertisements'));
    }
  } on Exception catch (e) {
    emit(CustomerAdvertisementError(error: e.toString()));
  }
}

  Future<void> _onCreateAdvertisement(
    CreateAdvertisement event,
    Emitter<CustomerAdvertisementState> emit,
  ) async {
    emit(CustomerAdvertisementLoading());

    final result = await advertisementRepo.createAdvertisement(
      discountPercentage: event.discount,
      durationInMilliSeconds: event.duration,
      paymentMethod: event.paymentMethod,
      description: event.description,
    );

    if (result.error != null) {
      emit(CustomerAdvertisementError(error: result.error!));
      return;
    }

    if (result.data != null) {
      if (result.data?.paymentResponse == null) {
        emit(AdvertisementCreated());
        return;
      }

     
      if (result.data!.paymentResponse != null) {
        emit(
          AdvertisementPaymentInitiatedState(result.data!.paymentResponse!),
        );
      }
    }
  }

  Future<void> _onGetAdvertPrice(
    FetchAdvertisementPrice event,
    Emitter<CustomerAdvertisementState> emit,
  ) async {
    emit(AdvertisementFetchPriceLoading());

    final result = await advertisementRepo.fetchAdvertPrice();

    if (result.error != null) {
      emit(CustomerAdvertisementError(error: result.error!));
    } else {
      final price = result.data;
      emit(AdvertisementPriceFetched(price: price));
    }
  }

  Future<void> _onVerifyAdvertisementPayment(
    VerifyAdvertisementPayment event,
    Emitter<CustomerAdvertisementState> emit,
  ) async {
    emit(AdvertisementPaymentVerifying());

    try {
      final result = await paymentRepo.verifyPayment(event.reference);

      if (result.isSuccess && result.data != null) {
        if (result.data!.gatewayResponse == 'Successful' ||
            result.data!.status == 'success') {
          emit(AdvertisementCreated());
        } else {
          emit(
            CustomerAdvertisementError(
              error: 'Payment was not successful: ${result.data!.gatewayResponse}',
            ),
          );
        }
      } else {
        emit(
          CustomerAdvertisementError(
            error: result.error ?? 'Payment verification failed',
          ),
        );
      }
    } on Exception catch (e) {
      log('Payment verification error: $e');
      emit(
        CustomerAdvertisementError(
          error: 'Payment verification failed: $e',
        ),
      );
    }
  }
}
