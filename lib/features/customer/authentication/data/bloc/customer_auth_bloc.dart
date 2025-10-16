import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/core/utils/build_config.dart';
import 'package:resq360/features/customer/authentication/data/models/auth_user.model.dart';
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
    on<CustomergetUserProfile>(_onGetUserProfile);
    on<CustomerLogout>(_onLogout);
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
      print('Forgot Password Result: $result'); // Debug line
      if (result) {
        emit(CustomerForgotPasswordSucess());
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
      // TODO: API call to reset password
      await Future.delayed(const Duration(seconds: 1));
      emit(CustomerAuthInitial()); // Or some success state
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
}
