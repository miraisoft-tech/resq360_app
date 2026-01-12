import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/features/settings/data/service/update_user_repo.dart';

part 'phone_update_event.dart';
part 'phone_update_state.dart';

final UpdateUserRepo updateUserRepo = UpdateUserRepo();

class PhoneUpdateBloc extends Bloc<PhoneUpdateEvent, PhoneUpdateState> {
  PhoneUpdateBloc() : super(PhoneUpdateInitial()) {
    on<RequestPhoneOtpEvent>(_onRequestPhoneOtp);
    on<VerifyPhoneOtpEvent>(_onVerifyPhoneOtp);
  }

  Future<void> _onRequestPhoneOtp(
    RequestPhoneOtpEvent event,
    Emitter<PhoneUpdateState> emit,
  ) async {
    emit(PhoneUpdateLoading());

    try {
      final result = await updateUserRepo.requestPhoneNumberOtp(
        newPhoneNumber: event.newPhoneNumber,
      );

      if (result.error != null) {
        emit(PhoneUpdateError(result.error!));
      } else {
        emit(PhoneOtpSent(event.newPhoneNumber));
      }
    } on Exception catch (e) {
      log('Request OTP failed: $e');
      emit(PhoneUpdateError(e.toString()));
    }
  }

  Future<void> _onVerifyPhoneOtp(
    VerifyPhoneOtpEvent event,
    Emitter<PhoneUpdateState> emit,
  ) async {
    emit(PhoneUpdateLoading());

    try {
      final result = await updateUserRepo.changePhoneNumber(
        newPhoneNumber: event.newPhoneNumber,
        otp: event.otp,
      );

      if (result.error != null) {
        emit(PhoneUpdateError(result.error!));
      } else {
        emit(PhoneUpdateSuccess(event.newPhoneNumber));
      }
    } on Exception catch (e) {
      log('Verify OTP failed: $e');
      emit(PhoneUpdateError(e.toString()));
    }
  }
}
