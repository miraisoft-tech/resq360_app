import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/auth_user.model.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/customer_user_model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth_remote.repo.dart';
import 'package:resq360/features/provider/authentication/data/models/state_model.dart';

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
    on<CustomerDeleteAccount>(_onDeleteAccount);
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

      if (result.data == null) {
        emit(CustomerAuthFailure(result.error ?? 'Login failed'));
        return;
      }
      final response = result.data!;
      final authData = response.data;

      if (authData?.isEmailVerified == false) {
        emit(CustomerAuthEmailPending());
        return;
      }

      if (authData?.accessToken == null || authData?.user == null) {
        emit(const CustomerAuthFailure('Invalid login response'));
        return;
      }

      final ok = await _loadAndSaveUserProfile(
        authResponse: result.data!,
      );

      if (!ok) {
        emit(const CustomerAuthFailure('Failed to load user profile'));
        return;
      }

      await AuthLocalRepo.instance.storeLocalCredentials(
        email: event.email,
        password: event.password,
      );

      emit(CustomerAuthLoginSuccess(authData!.user!));
    } on Exception catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  Future<void> _loginWithEmailSilently() async {
    try {
      final localCredentials =
          await AuthLocalRepo.instance.getLocalCredentials();

      final result = await authRemoteRepo.loginWithEmail(
        email: localCredentials?.userName ?? '',
        password: localCredentials?.password ?? '',
      );

      await _loadAndSaveUserProfile(
        authResponse: result.data!,
      );
    } on Exception catch (e) {
      log(e);
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

      if (result.data == null) {
        emit(CustomerAuthFailure(result.error ?? 'Signup failed'));
        return;
      }

      log(result.data.toString());

      final user = result.data?.user;
      if (user != null) {
        emit(CustomerAuthAuthenticated(user));
        await AuthLocalRepo.instance.storeLocalCredentials(
          email: event.email,
          password: event.password,
        );
      }
    } on Exception catch (e) {
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

      if (result.data ?? false) {
        emit(CustomerResetTokenValidatedState());
      } else {
        emit(
           CustomerAuthFailure(
            result.error ?? 'Invalid or expired reset token. Please request a new one.',
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
      if (result.data ?? false) {
        emit(CustomerPasswordResetSuccessState());
      } else {
        emit(
           CustomerAuthFailure(
            result.error ?? 'Password reset failed. Please try again.',
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

        await _loginWithEmailSilently();
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
    log('Fetching customer profile...');
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.getUserProfile();
      if (result.data != null) {
        await AuthLocalRepo.instance.storeUserDetails(
          customerProfileResponse: result.data,
          isProvider: false,
        );
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

  Future<void> _onDeleteAccount(
    CustomerDeleteAccount event,
    Emitter<CustomerAuthState> emit,
  ) async {
    emit(CustomerAuthLoading());

    try {
      final result = await authRemoteRepo.deleteAccount();

      if (result.data != null) {
        final message =
            result.data?['message'] ?? 'Account deleted successfully';
        emit(CustomerAccountDeletedState(message.toString()));
      } else {
        emit(
          CustomerAccountDeletionFailedState(
            result.error ?? 'Failed to delete account',
          ),
        );
      }
    } on Exception catch (e) {
      log('Delete Account Error: $e');
      emit(CustomerAccountDeletionFailedState(e.toString()));
    }
  }


  Future<bool> _loadAndSaveUserProfile({
    required AuthResponse authResponse,
  }) async {
    await AuthLocalRepo.instance.storeAccessToken(
      authResponse.data?.accessToken ?? '',
    );

    final res = await authRemoteRepo.getUserProfile();

    if (res.data == null) {
      return false;
    }

    await AuthLocalRepo.instance.storeUserDetails(
      customerProfileResponse: res.data,
      isProvider: false,
    );

    return true;
  }
}
