import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/identity_response.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/kyc_response.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/user_kyc.model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth_remote.repo.dart';

part 'customer_auth_event.dart';
part 'customer_auth_state.dart';

final AuthRemoteRepo authRemoteRepo = AuthRemoteRepo();

class CustomerAuthBloc extends Bloc<CustomerAuthEvent, CustomerAuthState> {
  CustomerAuthBloc() : super(CustomerAuthInitial()) {
    on<CustomerLoginWithEmail>(_onLoginWithEmail);
    on<CustomerSignupWIthEmail>(_onSignupWithEmail);
    on<CustomerForgotPassword>(_onForgotPassword);
    on<CustomerResetPassword>(_onResetPassword);
    on<CustomerverifyEmail>(_onVerifyEmail);
    on<CustomerResendVerificationOtp>(_onResendVerificationOtp);
    on<CustomergetUserProfile>(_onGetUserProfile);
    on<CustomerLogout>(_onLogout);
    on<CustomerSubmitKyc>(_onSubmitKyc);
    on<CustomerGetUserKycInfo>(_onGetUserKycInfo);
    on<CustomerSubmitKycAddress>(_onSubmitKycAddress);
    on<CustomerSubmitId>(_onSubmitKycId);
    
  }

  Future<void> _onLoginWithEmail(
    CustomerLoginWithEmail event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.loginWithEmail(
        email: event.email,
        password: event.password,
      );
      if (result.data != null) {
        emit(CustomerAuthLoginSuccess(result.data!.user));
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Login failed'));
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onSignupWithEmail(
    CustomerSignupWIthEmail event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.signupWithEmail(
        fullname: event.fullname,
        email: event.email,
        password: event.password,
      );
      if (result.data != null) {
        emit(CustomerAuthAuthenticated(result.data!.user));
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Signup failed'));
      }
    } on Exception catch (e) {
      log('Signup Bloc Error: $e');
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    CustomerForgotPassword event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.forgotPassword(
        email: event.email,
      );
      log('Forgot Password Result: $result');
      if (result) {
        emit(CustomerForgotPasswordOtpSent());
      } else {
        emit(
          const CustomerAuthFailure(
            'Failed to send password reset email. Please try again.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    CustomerResetPassword event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.resetPassword(
        password: event.password,
      );
      if (result) {
        emit(CustomerPasswordResetSuccess());
      } else {
        emit(
          const CustomerAuthFailure(
            'Password reset failed. Please check your code and try again.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }
  
  Future<void> _onVerifyEmail(
    CustomerverifyEmail event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.verifyEmail(
        emailVerificationToken: event.emailVerificationToken,
      );

      if (result) {
        emit(CustomerEmailVerified());
      } else {
        emit(
          const CustomerAuthFailure(
            'Verification failed. Please check your code.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }



Future<void> _onResendVerificationOtp(
  CustomerResendVerificationOtp event,
  Emitter<CustomerAuthState> emit,
) async {
  emit(CustomerAuthLoading());
  try {
    final result = await authRemoteRepo.resendVerificationOtp(event.email);

    if (result.error != null) {
      emit(CustomerAuthFailure(result.error!));
    } else {
      final message = result.data?['message'] ?? 'Verification OTP resent successfully';
      emit(CustomerVerificationResent(message.toString()));
    }
  } on Exception catch (e) {
    emit(CustomerAuthFailure('Failed to resend verification OTP: $e'));
  }
}


  // Get user profile
  Future<void> _onGetUserProfile(
    CustomergetUserProfile event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.getUserProfile();
      if (result.data != null) {
        emit(CustomerProfileLoaded(result.data!.user));
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Failed to load profile'));
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Logout
  void _onLogout(CustomerLogout event, Emitter<CustomerAuthState> emit) {
    // Clear user session if needed
    emit(CustomerAuthInitial());
  }

// KYC Submission
  Future<void> _onSubmitKyc(
    CustomerSubmitKyc event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.uploadAndSubmitFaceId(
        filePath: event.filePath,
      );
      if (result.data != null) {
        emit(CustomerKycSubmitted(result.data!));
      } else {
        emit(CustomerKycSubmissionFailure(result.error ?? 'KYC submission failed'));
      }
    } on Exception catch (e) {
      emit(CustomerKycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onGetUserKycInfo (
    CustomerGetUserKycInfo event,
    Emitter<CustomerAuthState> emit
  ) async {
    emit(CustomerAuthLoading());
    try{
      final result = await authRemoteRepo.getUserKycInfo();
      if (result.data != null){
        emit(CustomerUserKycInfoLoaded(result.data!));
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Failed to load KYC info'));
      }
    } on Exception catch (e) {
      log( 'CustomerGetUserKycInfo Bloc Get User KYC Info Error: $e');
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onSubmitKycAddress(
    CustomerSubmitKycAddress event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.submitKycAddress(
        address: event.address,
        city: event.city,
        state: event.state,
      );
      if (result) {
        emit(CustomerKycAddressSubmitted());
      } else {
        emit(CustomerKycSubmissionFailure('$result KYC address submission failed'));
      }
    } on Exception catch (e) {
      emit(CustomerKycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onSubmitKycId(
    CustomerSubmitId event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.uploadAndSubmitIdentity(
        documentType: event.documentType,
        filePath: event.filePath,
      );
      if (result.data != null) {
        emit( CustumerIdentitySubmitted(data: result.data!));
      } else {
        emit(CustomerKycSubmissionFailure(result.error ?? 'KYC ID submission failed'));
      }
    } on Exception catch (e) {
      emit(CustomerKycSubmissionFailure(e.toString()));
    }
  }
}
