import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/payment_repo.dart';

part 'customer_payment_event.dart';
part 'customer_payment_state.dart';

class CustomerPaymentBloc
    extends Bloc<CustomerPaymentEvent, CustomerPaymentState> {
  CustomerPaymentBloc({PaymentRepo? repo})
      : _repo = repo ?? PaymentRepo(),
        super(CustomerPaymentInitialState()) {
    on<CustomerInitWalletFundingEvent>(_initWalletFunding);
    on<CustomerVerifyWalletFundingEvent>(_verifyWalletFunding);

    on<CustomerInitServicePaymentEvent>(_initServicePayment);
    on<CustomerVerifyServicePaymentEvent>(_verifyServicePayment);
  }

  final PaymentRepo _repo;

  Future<void> _initWalletFunding(
    CustomerInitWalletFundingEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(WalletFundingLoadingState());

    final result = await _repo.fundWallet(
      amount: event.amount,
      userType: event.userType,
    );

    if (result.data != null) {
      emit(WalletFundingInitiatedState(result.data!));
    } else {
      log(result.error);
      emit(WalletFundingFailureState(
        result.error ?? 'Wallet funding failed',
      ));
    }
  }

  Future<void> _verifyWalletFunding(
    CustomerVerifyWalletFundingEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(WalletFundingLoadingState());

    final result = await _repo.verifyPayment(event.reference);

    if (result.isSuccess && result.data != null) {
      emit(WalletFundingVerifiedState(result.data!));
    } else {
      emit(WalletFundingFailureState(
        result.error ?? 'Wallet funding verification failed',
      ));
    }
  }


  Future<void> _initServicePayment(
    CustomerInitServicePaymentEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(ServicePaymentLoadingState());

    final result = await _repo.initiatePayment(
      amount: event.amount,
      email: event.email,
      currency: event.currency,
      callbackUrl: event.callbackUrl,
    );

    if (result.data != null) {
      emit(ServicePaymentInitiatedState(result.data!));
    } else {
      emit(ServicePaymentFailureState(
        result.error ?? 'Service payment initiation failed',
      ));
    }
  }

  Future<void> _verifyServicePayment(
    CustomerVerifyServicePaymentEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(ServicePaymentLoadingState());

    final result = await _repo.verifyPayment(event.reference);

    if (result.isSuccess && result.data != null) {
      emit(ServicePaymentVerifiedState(result.data!));
    } else {
      emit(ServicePaymentFailureState(
        result.error ?? 'Service payment verification failed',
      ));
    }
  }
}
