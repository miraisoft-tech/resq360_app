import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/models/kyc/identity_response.dart';
import 'package:resq360/core/models/kyc/kyc_response.model.dart';
import 'package:resq360/core/models/kyc/user_kyc.model.dart';
import 'package:resq360/features/customer/authentication/data/service/auth_remote.repo.dart';
import 'package:resq360/features/provider/authentication/data/models/state_model.dart';

part 'kyc_event.dart';
part 'kyc_state.dart';


final AuthRemoteRepo _authRemoteRepo = AuthRemoteRepo();

class KycBloc extends Bloc<KycEvent, KycState> {
  KycBloc() : super(KycInitial()) {
    on<SubmitKyc>(_onSubmitKyc);
    on<GetUserKycInfo>(_onGetUserKycInfo);
    on<SubmitKycAddress>(_onSubmitKycAddress);
    on<SubmitId>(_onSubmitKycId);
    on<GetStates>(_getLocalStates);
  }

  Future<void> _onSubmitKyc(
    SubmitKyc event,
    Emitter<KycState> emit,
  ) async {
    emit(KycFaceLoading());
    try {
      final result = await _authRemoteRepo.uploadAndSubmitFaceId(
        filePath: event.filePath,
      );
      if (result.data != null) {
        emit(KycSubmitted(result.data!));
      } else {
        emit(
          KycFailure(result.error ?? 'KYC submission failed'),
        );
      }
    } on Exception catch (e) {
      emit(KycFailure(e.toString()));
    }
  }

  Future<void> _onGetUserKycInfo(
    GetUserKycInfo event,
    Emitter<KycState> emit,
  ) async {
    emit(KycInfoLoading());
    try {
      final result = await _authRemoteRepo.getUserKycInfo();
      if (result.data != null) {
        emit(UserKycInfoLoaded(result.data!));
      } else {
        emit(KycFailure(result.error ?? 'Failed to load KYC info'));
      }
    } on Exception catch (e) {
      log('GetUserKycInfo Bloc Get User KYC Info Error: $e');
      emit(KycFailure(e.toString()));
    }
  }


  Future<void> _onSubmitKycAddress(
    SubmitKycAddress event,
    Emitter<KycState> emit,
  ) async {
    emit(KycAddressLoading());
    try {
      final result = await _authRemoteRepo.submitKycAddress(
        address: event.address,
        city: event.city,
        state: event.state,
      );
      if (result) {
        emit(KycAddressSubmitted());
      } else {
        emit(
          KycFailure('$result KYC address submission failed'),
        );
      }
    } on Exception catch (e) {
      emit(KycFailure(e.toString()));
    }
  }

  Future<void> _onSubmitKycId(
    SubmitId event,
    Emitter<KycState> emit,
  ) async {
    emit(KycIdLoading());
    try {
      final result = await _authRemoteRepo.uploadAndSubmitIdentity(
        documentType: event.documentType,
        filePath: event.filePath,
      );
      if (result.data != null) {
        emit(IdentitySubmitted(data: result.data!));
      } else {
        emit(
          KycFailure(
            result.error ?? 'KYC ID submission failed',
          ),
        );
      }
    } on Exception catch (e) {
      emit(KycFailure(e.toString()));
    }
  }

  Future<void> _getLocalStates(
    GetStates event,
    Emitter<KycState> emit,
  ) async {
    final tempStatesList = <StateModel>[];
    emit(StatesLoading());
    try {
      final jsonString = await rootBundle.loadString(
        'assets/json/states_list.json',
      );
      final json = jsonDecode(jsonString);

      if (json == null || json is! List) {
        emit(StatesLoadedState(tempStatesList));
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

      emit(StatesLoadedState(tempStatesList));
    } on Exception catch (e) {
      log('Error loading states: $e');
      emit(StatesLoadedState(tempStatesList));
    }
  }
}
