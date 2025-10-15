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

  // Example login handler
  Future<void> _onLoginWithEmail(
      CustomerLoginWithEmail event, Emitter<CustomerAuthState> emit) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.loginWithEmail(
        email: event.email,
        password: event.password,
      );
       if (result.data != null) {
      emit(CustomerAuthAuthenticated(result.data!.user));
    } else {
      emit(CustomerAuthFailure(result.error ?? 'Signup failed'));
    }
    } catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }


  Future<void> _onSignupWithEmail(
      CustomerSignupWIthEmail event, Emitter<CustomerAuthState> emit) async {
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
    } catch (e) {
       log('Signup Bloc Error: $e');
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Forgot password
  Future<void> _onForgotPassword(
      CustomerForgotPassword event, Emitter<CustomerAuthState> emit) async {
    emit(CustomerAuthLoading());
    try {
      // TODO: API call to request password reset
      await Future.delayed(const Duration(seconds: 1));
      emit(CustomerAuthInitial()); // Can emit a "success message" state if needed
    } catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Reset password
  Future<void> _onResetPassword(
      CustomerResetPassword event, Emitter<CustomerAuthState> emit) async {
    emit(CustomerAuthLoading());
    try {
      // TODO: API call to reset password
      await Future.delayed(const Duration(seconds: 1));
      emit(CustomerAuthInitial()); // Or some success state
    } catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Email verification
  Future<void> _onVerifyEmail(
      CustomerverifyEmail event, Emitter<CustomerAuthState> emit) async {
    emit(CustomerAuthLoading());
    try {
      final result = await authRemoteRepo.verifyEmail(
        emailVerificationToken: event.emailVerificationToken,
      );

      final isVerified = result;
      if (isVerified) {
        emit(CustomerEmailVerified());
      }
    } catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Get user profile
  Future<void> _onGetUserProfile(
      CustomergetUserProfile event, Emitter<CustomerAuthState> emit) async {
    emit(CustomerAuthLoading());
    try {
      // TODO: API call to fetch profile
      await Future.delayed(const Duration(seconds: 1));
      final userId = "customer_123"; // Example response
      // emit(CustomerAuthAuthenticated(userId));
    } catch (e) {
      emit(CustomerAuthFailure(e.toString()));
    }
  }

  // Logout
  void _onLogout(CustomerLogout event, Emitter<CustomerAuthState> emit) {
    // Clear user session if needed
    emit(CustomerAuthInitial());
  }
}
