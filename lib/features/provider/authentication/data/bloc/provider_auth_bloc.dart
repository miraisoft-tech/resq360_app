import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/features/customer/authentication/data/bloc/customer_auth_bloc.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/identity_response.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/kyc_response.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/user_kyc.model.dart';
import 'package:resq360/features/provider/authentication/data/models/address.model.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/authentication/data/service/provider_auth_remote.repo.dart';

part 'provider_auth_event.dart';
part 'provider_auth_state.dart';

final ProviderAuthRemoteRepo providerAuthRemoteRepo = ProviderAuthRemoteRepo();

class ProviderAuthBloc extends Bloc<ProviderAuthEvent, ProviderAuthState> {
  ProviderAuthBloc() : super(ProviderAuthInitial()) {
    on<ProviderLoginWithEmail>(_onLoginWithEmail);
    on<ProviderSignupWIthEmail>(_onSignupWithEmail);
    on<ProviderRequestPasswordResetEvent>(_onRequestPasswordReset);
    on<ProviderValidateResetTokenEvent>(_onValidateResetToken);
    on<ProviderSetNewPasswordEvent>(_onSetNewPassword);
    on<ProviderVerifyEmailAddressEvent>(_onVerifyEmailAddress);
    on<ProviderResendVerificationEmailEvent>(_onResendVerificationEmail);
    on<ProvidergetProviderProfile>(_onGetProviderProfile);
    on<ProviderSubmitKyc>(_onSubmitKyc);
    on<ProviderSubmitKycAddress>(_onSubmitKycAddress);
    on<ProviderSubmitId>(_onSubmitKycId);
    on<ProviderGetProividerKycInfo>(_onGetProviderKycInfo);
    on<ProviderLogout>(_onLogout);
  }

  Future<void> _onLoginWithEmail(
    ProviderLoginWithEmail event,
    Emitter<ProviderAuthState> emit, [
    bool showLoading = true,
  ]) async {
    if (showLoading) emit(ProviderAuthLoadingState());

    try {
      final result = await providerAuthRemoteRepo.loginWithEmail(
        email: event.email,
        password: event.password,
      );

      if (result.data == null) {
        log('bloc error ${result.error}');
        emit(ProviderAuthFailureState(result.error ?? 'Login failed'));
        return;
      }

      final ok = await _loadAndSaveProviderProfile(
        authResponse: result.data!,
      );

      if (!ok) {
        emit(const ProviderAuthFailureState('Failed to load profile'));
        return;
      }

      await AuthLocalRepo.instance.storeLocalCredentials(
        email: event.email,
        password: event.password,
      );

      emit(ProviderAuthLoginSuccessState(result.data!.provider));
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _loginWithEmailSilently() async {
    try {
      final localCredentials =
          await AuthLocalRepo.instance.getLocalCredentials();

      final result = await providerAuthRemoteRepo.loginWithEmail(
        email: localCredentials?.userName ?? '',
        password: localCredentials?.password ?? '',
      );

      await _loadAndSaveProviderProfile(
        authResponse: result.data!,
      );
    } on Exception catch (e) {
      log(e);
    }
  }

  Future<bool> _loadAndSaveProviderProfile({
    required AuthResponse authResponse,
  }) async {
    await AuthLocalRepo.instance.storeAccessToken(
      authResponse.accessToken ?? '',
    );

    final res = await providerAuthRemoteRepo.getProviderProfile();
    if (res.data == null) return false;

    await AuthLocalRepo.instance.storeUserDetails(
      isProvider: true,
      providerProfileResponse: res.data,
    );

    return true;
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

      if (result.data == null) {
        emit(ProviderAuthFailureState(result.error ?? 'Signup failed'));
        return;
      }

      await AuthLocalRepo.instance.storeLocalCredentials(
        email: event.email,
        password: event.password,
      );

      emit(ProviderAuthSignupSuccessState(result.data!.provider));
    } on Exception catch (e) {
      log('Signup Bloc Error: $e');
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  Future<void> _onRequestPasswordReset(
    ProviderRequestPasswordResetEvent event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.requestPasswordReset(
        email: event.email,
      );
      log('Forgot Password Result: $result');
      if (result) {
        emit(ProviderPasswordResetEmailSentState());
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

  Future<void> _onValidateResetToken(
    ProviderValidateResetTokenEvent event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.validateResetToken(
        token: event.token,
      );

      if (result) {
        emit(ProviderResetTokenValidatedState());
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

  Future<void> _onSetNewPassword(
    ProviderSetNewPasswordEvent event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.setNewPassword(
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

  Future<void> _onVerifyEmailAddress(
    ProviderVerifyEmailAddressEvent event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.verifyEmailAddress(
        emailVerificationToken: event.emailVerificationToken,
      );

      if (result) {
        emit(ProviderEmailVerifiedState());

        await _loginWithEmailSilently();
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

  Future<void> _onResendVerificationEmail(
    ProviderResendVerificationEmailEvent event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.resendVerificationEmail(
        event.email,
      );

      if (result.error != null) {
        emit(ProviderAuthFailureState(result.error!));
      } else {
        final message =
            result.data?['message'] ?? 'Verification OTP resent successfully';
        emit(ProviderVerificationEmailResentState(message.toString()));
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState('Failed to resend verification OTP: $e'));
    }
  }

  Future<void> _onGetProviderProfile(
    ProvidergetProviderProfile event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.getProviderProfile();
      if (result.data != null) {
        await AuthLocalRepo.instance.storeUserDetails(
          isProvider: true,
          providerProfileResponse: result.data,
        );
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
