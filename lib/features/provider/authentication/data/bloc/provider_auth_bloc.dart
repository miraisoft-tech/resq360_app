import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_user.model.dart';
import 'package:resq360/features/provider/authentication/data/service/auth_remote.repo.dart';

part 'provider_auth_event.dart';
part 'provider_auth_state.dart';

final ProviderAuthRemoteRepo providerAuthRemoteRepo = ProviderAuthRemoteRepo();

class ProviderAuthBloc extends Bloc<ProviderAuthEvent, ProviderAuthState> {
  ProviderAuthBloc() : super(ProviderAuthInitial()) {

      on<ProviderLoginWithEmail>(_onLoginWithEmail);
      on<ProviderSignupWIthEmail>(_onSignupWithEmail);
      on<ProviderForgotPassword>(_onForgotPassword);
      on<ProviderResetPassword>(_onResetPassword);
      on<ProviderverifyEmail>(_onVerifyEmail);
      on<ProvidergetUserProfile>(_onGetUserProfile);
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
        final userProfile = await providerAuthRemoteRepo.getUserProfile();

        log('Fetched user profile: $userProfile'); // test line

        emit(ProviderAuthAuthenticatedState(result.data!.user));
      } else {
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
        emit(ProviderAuthSignupSuccessState(result.data!.user));
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
      print('Forgot Password Result: $result'); // Debug line
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
      // TODO: API call to reset password
      // success state
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

  // Get user profile
  Future<void> _onGetUserProfile(
    ProvidergetUserProfile event,
    Emitter<ProviderAuthState> emit,
  ) async {
    emit(ProviderAuthLoadingState());
    try {
      final result = await providerAuthRemoteRepo.getUserProfile();
      if (result.data != null) {
        emit(ProviderProfileLoadedState(result.data!.user));
      } else {
        emit(
          ProviderAuthFailureState(result.error ?? 'Failed to load profile'),
        );
      }
    } on Exception catch (e) {
      emit(ProviderAuthFailureState(e.toString()));
    }
  }

  // Logout
  void _onLogout(ProviderLogout event, Emitter<ProviderAuthState> emit) {
    // Clear user session if needed
    emit(ProviderAuthInitial());
  }
}
