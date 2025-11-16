import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/identity_response.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/kyc_response.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/user_kyc.model.dart';
import 'package:resq360/features/provider/authentication/data/models/address.model.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/authentication/data/service/auth_remote.repo.dart';

part 'provider_auth_event.dart';
part 'provider_auth_state.dart';

final ProviderAuthRemoteRepo providerAuthRemoteRepo = ProviderAuthRemoteRepo();

class ProviderAuthBloc extends Bloc<ProviderAuthEvent, ProviderAuthState> {
  ProviderAuthBloc() : super(ProviderAuthInitial()) {
    on<ProviderLoginWithEmail>(_onLoginWithEmail);
    on<ProviderSignupWIthEmail>(_onSignupWithEmail);
    on<ProviderForgotPassword>(_onForgotPassword);
    on<ProviderVerifyForgotPasswordOtp>(_onVerifyForgotPasswordOtp);
    on<ProviderResetPassword>(_onResetPassword);
    on<ProviderverifyEmail>(_onVerifyEmail);
    on<ProviderResendVerificationOtp>(_onResendVerificationOtp);
    on<ProvidergetUserProfile>(_onGetUserProfile);
    on<ProviderSubmitKyc>(_onSubmitKyc);
    on<ProviderSubmitKycAddress>(_onSubmitKycAddress);
    on<ProviderSubmitId>(_onSubmitKycId);
    on<ProviderGetProividerKycInfo>(_onGetProviderKycInfo);
    on<ProviderLogout>(_onLogout);
  }

  Future<void> _onLoginWithEmail(
    ProviderLoginWithEmail event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.loginWithEmail(
        email: event.email,
        password: event.password,
      );
      if (result.data != null) {
        emit(ProviderAuthLoginSuccessState(result.data!.provider));
      } else {
        log('bloc error ${result.error}');
        emit(ProviderAuthFailureState(result.error ?? 'Signup failed'));
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onSignupWithEmail(
    ProviderSignupWIthEmail event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.signupWithEmail(
        fullname: event.fullname,
        email: event.email,
        password: event.password,
        companyName: event.companyName,
        phoneNumber: event.phoneNumber,
        customServiceName: event.customServiceName,
        service: event.service,
        address: event.address,
      );
      if (result.data != null) {
        emit(ProviderAuthSignupSuccessState(result.data!.provider));
      } else {
        emit(ProviderAuthFailureState(result.error ?? 'Signup failed'));
      }
    } on Exception catch (e) {
      log('Signup Bloc Error: $e');
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onForgotPassword(
    ProviderForgotPassword event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.forgotPassword(
        email: event.email,
      );
      log('Forgot Password Result: $result');
      if (result) {
        emit(ProviderForgotPasswordSucessState());
      } else {
        emit(
          const ProviderAuthFailureState(
            'Failed to send password reset email. Please try again.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onResetPassword(
    ProviderResetPassword event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.resetPassword(
        password: event.password,
      );
      if (result) {
        emit(ProviderResetPasswordSuccesState());
      } else {
        emit(
          const ProviderAuthFailureState(
            'Failed to send password reset email. Please try again.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onVerifyForgotPasswordOtp(
    ProviderVerifyForgotPasswordOtp event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.forgotPasswordVerifyEmail(
        token: event.token,
      );

      if (result) {
        emit(ProviderForgotPasswordOtpVerified());
      } else {
        emit(
          const ProviderAuthFailureState(
            'Verification failed. Please check your code.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onVerifyEmail(
    ProviderverifyEmail event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.verifyEmail(
        emailVerificationToken: event.emailVerificationToken,
      );

      if (result) {
        emit(ProviderEmailVerifiedState());
      } else {
        emit(
          const ProviderAuthFailureState(
            'Verification failed. Please check your code.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onResendVerificationOtp(
    ProviderResendVerificationOtp event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.resendVerificationOtp(
        event.email,
      );

      if (result.error != null) {
        emit(ProviderAuthFailureState(result.error!));
      } else {
        final message =
            result.data?['message'] ?? 'Verification OTP resent successfully';
        emit(ProviderVerificationResent(message.toString()));
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState('Failed to resend verification OTP: $e'));
    }
  }

  Future<void> _onGetUserProfile(
    ProvidergetUserProfile event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.getUserProfile();
      if (result.data != null) {
        emit(ProviderProfileLoadedState(result.data!));
      } else {
        emit(
          ProviderAuthFailureState(result.error ?? 'Failed to load profile'),
        );
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  void _onLogout(ProviderLogout event, Emitter<ProviderAuthState> emit) {
  
    emit(ProviderAuthInitial());
  }

  Future<void> _onSubmitKyc(
    ProviderSubmitKyc event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await authRemoteRepo.uploadAndSubmitFaceId(
        filePath: event.filePath,
      );
      if (result.data != null) {
        emit(ProviderKycSubmitted(result.data!));
      } else {
        emit(
          ProviderKycSubmissionFailure(result.error ?? 'KYC submission failed'),
        );
      }
    } on Exception catch (e) {
      emit(ProviderKycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onGetProviderKycInfo(
    ProviderGetProividerKycInfo event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await authRemoteRepo.getUserKycInfo();
      if (result.data != null) {
        emit(ProviderKycInfoLoaded(result.data!));
      } else {
        emit(
          ProviderAuthFailureState(result.error ?? 'Failed to load KYC info'),
        );
      }
    } on Exception catch (e) {
      log('ProviderGetUserKycInfo Bloc Get provider KYC Info Error: $e');
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onSubmitKycAddress(
    ProviderSubmitKycAddress event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await authRemoteRepo.submitKycAddress(
        address: event.address,
        city: event.city,
        state: event.state,
      );
      if (result) {
        emit(ProviderKycAddressSubmitted());
      } else {
        emit(
          ProviderKycSubmissionFailure('$result KYC address submission failed'),
        );
      }
    } on Exception catch (e) {
      emit(ProviderKycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onSubmitKycId(
    ProviderSubmitId event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await authRemoteRepo.uploadAndSubmitIdentity(
        documentType: event.documentType,
        filePath: event.filePath,
      );
      if (result.data != null) {
        emit(ProviderIdentitySubmitted(data: result.data!));
      } else {
        emit(
          ProviderKycSubmissionFailure(
            result.error ?? 'KYC ID submission failed',
          ),
        );
      }
    } on Exception catch (e) {
      emit(ProviderKycSubmissionFailure(e.toString()));
    }
  }
}
