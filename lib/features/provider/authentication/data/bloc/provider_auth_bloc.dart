import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';

import 'package:resq360/features/provider/authentication/data/models/address.model.dart';
import 'package:resq360/features/provider/authentication/data/models/auth_provider.model.dart';
import 'package:resq360/features/provider/authentication/data/models/provider_response.dart';
import 'package:resq360/features/provider/authentication/data/models/state_model.dart';
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
     on<ProviderDeleteAccount>(_onDeleteAccount);
    on<ProviderLogout>(_onLogout);
    on<ProviderGetStates>(_getLocalStates);
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

      final response = result.data;
      final authData = response?.data;

      if (response == null || authData == null) {
        emit(ProviderAuthFailureState(result.error ?? 'Login failed'));
        return;
      }

      if (authData.isEmailVerified == false) {
        emit(ProviderAuthEmailPendingState());
        return;
      }

      if (authData.accessToken != null && authData.provider != null) {
        await AuthLocalRepo.instance.storeAccessToken(authData.accessToken!);
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

        emit(ProviderAuthLoginSuccessState(authData.provider!));
        return;
      }
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

      final response = result.data;
      if (response == null) {
        emit(ProviderAuthFailureState(result.error ?? 'Signup failed'));
        return;
      }

      final provider = result.data?.provider;
      if (provider == null) {
        emit(const ProviderAuthFailureState('Invalid signup response'));
        return;
      }

      emit(ProviderAuthSignupSuccessState(provider));
      await AuthLocalRepo.instance.storeLocalCredentials(
        email: event.email,
        password: event.password,
      );
      
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
      log( 'Fetching provider profile...');
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

  Future<void> _onDeleteAccount(
  ProviderDeleteAccount event,
  Emitter<ProviderAuthState> emit,
) async {
  emit(ProviderAuthLoadingState());
  
  try {
    final result = await providerAuthRemoteRepo.deleteAccount();
    
    if (result.data != null) {
      final message = result.data?['message'] ?? 'Account deleted successfully';
      emit(ProviderAccountDeletedState(message.toString()));
    } else {
      emit(
        ProviderAccountDeletionFailedState(
          result.error ?? 'Failed to delete account',
        ),
      );
    }
  } on Exception catch (e) {
    log('Delete Account Error: $e');
    emit(ProviderAccountDeletionFailedState(e.toString()));
  }
}

  Future<void> _getLocalStates(
    ProviderGetStates event,
    Emitter<ProviderAuthState> emit,
  ) async {
    final tempStatesList = <StateModel>[];
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/states_list.json',
      );
      final json = jsonDecode(jsonString);

      if (json == null || json is! List) {
        emit(ProviderStatesLoadedState(tempStatesList));
        return;
      }

      final statesListJson = json;
      log('states ${statesListJson.length}');

      for (var i = 0; i < statesListJson.length; i++) {
        final stateJson = statesListJson[i];
        if (stateJson is String) {
          tempStatesList.add(StateModel.fromJson(stateJson));
        }
      }

      tempStatesList.sort((a, b) {
        final nameA = a.name ?? '';
        final nameB = b.name ?? '';
        return nameA.compareTo(nameB);
      });

      emit(ProviderStatesLoadedState(tempStatesList));
    } on Exception catch (e) {
      log('Error loading states: $e');
      emit(ProviderStatesLoadedState(tempStatesList));
    }
  }

    Future<bool> _loadAndSaveProviderProfile({
    required AuthResponse authResponse,
  }) async {
    await AuthLocalRepo.instance.storeAccessToken(
      authResponse.data?.accessToken ?? '',
    );

    final res = await providerAuthRemoteRepo.getProviderProfile();
    if (res.data == null) return false;

    await AuthLocalRepo.instance.storeUserDetails(
      isProvider: true,
      providerProfileResponse: res.data,
    );

    return true;
  }

}
