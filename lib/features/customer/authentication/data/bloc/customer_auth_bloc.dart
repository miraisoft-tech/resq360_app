import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';
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
    on<CustomerRequestPasswordResetEvent>(_onRequestPasswordReset);
    on<CustomerValidateResetTokenEvent>(_onValidateResetToken);
    on<CustomerSetNewPasswordEvent>(_onSetNewPassword);
    on<CustomerVerifyEmailAddressEvent>(_onVerifyEmailAddress);
    on<CustomerResendVerificationEmailEvent>(_onResendVerificationEmail);
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
        final profileResult = await authRemoteRepo.getUserProfile();

        if (profileResult.data != null) {
          emit(CustomerAuthLoginSuccess(result.data!.user));
        } else {
          emit(
            CustomerAuthFailure(
              profileResult.error ?? 'Failed to load profile',
            ),
          );
        }
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
        final profileResult = await authRemoteRepo.getUserProfile();

        if (profileResult.data != null) {
          emit(CustomerAuthAuthenticated(result.data!.user));
        } else {
          emit(
            CustomerAuthFailure(
              profileResult.error ?? 'Failed to load profile',
            ),
          );
        }
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Signup failed'));
      }
    } on Exception catch (e) {
      log('Signup Bloc Error: $e');
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onRequestPasswordReset(
    CustomerRequestPasswordResetEvent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.requestPasswordReset(
        email: event.email,
      );
      log('Password Reset Request Result: $result');
      if (result) {
        emit(CustomerPasswordResetEmailSentState());
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

  Future<void> _onValidateResetToken(
    CustomerValidateResetTokenEvent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.validateResetToken(
        token: event.token,
      );

      if (result) {
        emit(CustomerResetTokenValidatedState());
      } else {
        emit(
          const CustomerAuthFailure(
            'Invalid or expired reset token. Please request a new one.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onSetNewPassword(
    CustomerSetNewPasswordEvent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.setNewPassword(
        password: event.password,
      );
      if (result) {
        emit(CustomerPasswordResetSuccessState());
      } else {
        emit(
          const CustomerAuthFailure(
            'Password reset failed. Please try again.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onVerifyEmailAddress(
    CustomerVerifyEmailAddressEvent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.verifyEmailAddress(
        emailVerificationToken: event.emailVerificationToken,
      );

      if (result) {
        emit(CustomerEmailVerified());
      } else {
        emit(
          const CustomerAuthFailure(
            'Email verification failed. Please check your verification link.',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _onResendVerificationEmail(
    CustomerResendVerificationEmailEvent event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.resendVerificationEmail(event.email);

      if (result.error != null) {
        emit(CustomerAuthFailure(result.error!));
      } else {
        final message =
            result.data?['message'] ?? 'Verification email resent successfully';
        emit(CustomerVerificationEmailResentState(message.toString()));
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure('Failed to resend verification email: $e'));
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
        emit(CustomerProfileLoaded(result.data!));
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Failed to load profile'));
      }
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Logout
  void _onLogout(CustomerLogout event, Emitter<CustomerAuthState> emit) {
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
        emit(
          CustomerKycSubmissionFailure(result.error ?? 'KYC submission failed'),
        );
      }
    } on Exception catch (e) {
      emit(CustomerKycSubmissionFailure(e.toString()));
    }
  }

  Future<void> _onGetUserKycInfo(
    CustomerGetUserKycInfo event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.getUserKycInfo();
      if (result.data != null) {
        emit(CustomerUserKycInfoLoaded(result.data!));
      } else {
        emit(CustomerAuthFailure(result.error ?? 'Failed to load KYC info'));
      }
    } on Exception catch (e) {
      log('CustomerGetUserKycInfo Bloc Get User KYC Info Error: $e');
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
        emit(
          CustomerKycSubmissionFailure('$result KYC address submission failed'),
        );
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
        emit(CustumerIdentitySubmitted(data: result.data!));
      } else {
        emit(
          CustomerKycSubmissionFailure(
            result.error ?? 'KYC ID submission failed',
          ),
        );
      }
    } on Exception catch (e) {
      emit(CustomerKycSubmissionFailure(e.toString()));
    }
  }
}
