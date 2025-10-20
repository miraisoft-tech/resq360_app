import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/customer/dashboard/data/models/payment/payment.model.dart';
import 'package:resq360/features/customer/dashboard/data/service/payment_repo.dart';

part 'customer_payment_event.dart';
part 'customer_payment_state.dart';
 
 final PaymentRepo paymentRepo = PaymentRepo();

class CustomerPaymentBloc extends Bloc<CustomerPaymentEvent, CustomerPaymentState> {
  CustomerPaymentBloc() : super(CustomerPaymentInitialState()) {
    on<CustomerPaymentEvent>((event, emit) {
    });
    on<CustomerInitializePaymentEvent>(_onInitializePayment);
    on<CustomerVerifyPaymentEvent>(_onVerifyPayment);
    on<CustomerPaystackPaymentEvent>(_onPaystackPayment);
  }

  Future<void> _onInitializePayment(
    CustomerInitializePaymentEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(CustomerPaymentLoadingState());
    try {
      final result = await paymentRepo.initiatePayment(
        amount: event.amount,
        email: event.email,
        currency: event.currency,
        callbackUrl: event.callbackUrl,
        );
      if (result.data != null && result.isSuccess) {
        log( 'bloc payment initiated: ${result.data}');
      emit(CustomerPaymentSuccessState(result.data!));
      } else {
        emit(CustomerPaymentFailureState(result.error ?? 'Failed to initiate payment'));
      }
      log('bloc Payment initiation result: ${result.data}, Error: ${result.error}');
      emit(const CustomerPaymentFailureState('Error message'));
    } on Exception catch (e) {
      log('Bloc Payment initiation exception: $e');
      emit(CustomerPaymentFailureState(e.toString()));
    }
  }

  Future<void> _onVerifyPayment(
    CustomerVerifyPaymentEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(CustomerPaymentLoadingState());
    try {
      final result = await paymentRepo.verifyPayment(event.reference);
      if (result.data != null && result.isSuccess) {
        log('Bloc Payment verification successful: ${result.data}');
        emit(CustomerPaymentVerifiedState(result.data!));
      } else {
        emit(CustomerPaymentFailureState(result.error ?? 'Failed to verify payment'));
      }
      log('Bloc Payment verification result: ${result.data}, Error: ${result.error}');
    } on Exception catch (e) {
      log('Bloc Payment verification exception: $e');
      emit(CustomerPaymentFailureState(e.toString()));
    }
  }

  Future<void> _onPaystackPayment(
    CustomerPaystackPaymentEvent event,
    Emitter<CustomerPaymentState> emit,
  ) async {
    emit(CustomerPaymentLoadingState());
    try {
      final result = await paymentRepo.payStackPayment();
      if (result.data != null && result.isSuccess) {
        log('Bloc Paystack payment completed: ${result.data}');
        emit(CustomerPaystackPaymentCompletedState());
      } else {
        emit(CustomerPaymentFailureState(result.error ?? 'Failed to complete Paystack payment'));
      }
      log('Bloc Paystack payment result: ${result.data}, Error: ${result.error}');
    } on Exception catch (e) {
      log('Bloc Paystack payment exception: $e');
      emit(CustomerPaymentFailureState(e.toString()));
    }
  }
}
