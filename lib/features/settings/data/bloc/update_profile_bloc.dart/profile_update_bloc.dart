import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/features/intro/models/user_type.emum.dart';
import 'package:resq360/features/main_layout_provider.dart';
import 'package:resq360/features/settings/data/service/update_user_repo.dart';

part 'profile_update_event.dart';
part 'profile_update_state.dart';

final UpdateUserRepo updateUserRepo = UpdateUserRepo();
final UploadService uploadService = UploadService.instance;

class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  ProfileUpdateBloc() : super(ProfileUpdateInitial()) {
    on<UpdateUserInfoEvent>(_onUpdateUserInfo);
    on<UpdateProviderInfoEvent>(_onUpdateProviderInfo);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
    on<UpdateProviderServiceEvent>(_onUpdateProviderService);
    on<UpdateProviderAddressEvent>(_onUpdateProviderAddress);
    on<UpdateBankAccountEvent>(_onUpdateBankAccount);
  }

  Future<void> _onUpdateUserInfo(
    UpdateUserInfoEvent event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    final result = await updateUserRepo.updateUserInformation(
      fullName: event.fullName,
      phoneNumber: event.phoneNumber,
      profileImageUrl: event.profileImageUrl,
      profileImageId: event.profileImageId,
    );

    if (result.error != null) {
      emit(ProfileUpdateError(result.error!));
    } else {
      emit(ProfileUpdateSuccess(result.data));
    }
  }

  Future<void> _onUpdateProviderInfo(
    UpdateProviderInfoEvent event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    emit(ProfileUpdateLoading());

    try {
      List<String>? uploadedImagesUrls;

      final imagesEvent = event.images;
      if (imagesEvent != null && imagesEvent.isNotEmpty) {
        final uploadedMultipleImagesResult = await uploadService.uploadMultiple(
          files: imagesEvent,
        );

        if (uploadedMultipleImagesResult.error != null) {
          emit(ProfileUpdateError(uploadedMultipleImagesResult.error!));
          return;
        }

        final uploadedImagesList = uploadedMultipleImagesResult.data;

        if (uploadedImagesList != null && uploadedImagesList.isNotEmpty) {
          uploadedImagesUrls =
              uploadedImagesList.map((img) => img.url).toList();

          for (var i = 0; i < uploadedImagesList.length; i++) {
            log('Uploaded image $i: ${uploadedImagesList[i].url}');
          }
        }
      }

      final provider = await AuthLocalRepo.instance.getProviderCredentials();
      if (provider == null) {
        log('No user');
        emit(const ProfileUpdateError('No user credentials found'));
        return;
      }

      final result = await updateUserRepo.updateProviderInformation(
        fullName: provider.fullName,
        phoneNumber: provider.phoneNumber,
        companyName: provider.companyName,
        description: event.description,
        workingDays: event.workingDays,
        openingHours: event.openingHours,
        closingHours: event.closingHours,
        activityStatus: 'online',
        images: uploadedImagesUrls,
      );

      if (result.error != null) {
        emit(ProfileUpdateError(result.error!));
      } else {
        emit(ProfileUpdateSuccess(result.data));
      }
    } on Exception catch (e, s) {
      log('Update provider failed: $e\n$s');
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> _onUpdateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    log('loading');
    try {
      log('uploading');
      final uploadResult = await uploadService.uploadSingle(
        filePath: event.filePath,
      );

      if (uploadResult.error != null) {
        emit(ProfileUpdateError(uploadResult.error!));
        return;
      }

      final uploaded = uploadResult.data!;

      final isProvider = dashboardViewModel.userType == UserType.provider;

      if (isProvider) {
        await updateUserRepo.updateProviderInformation(
          profileImageId: uploaded.id,
          profileImageUrl: uploaded.url,
        );
      } else {
        final user = await AuthLocalRepo.instance.getAuthCredentials();

        if (user == null) {
          emit(const ProfileUpdateError('No user found'));
          return;
        }

        await updateUserRepo.updateUserInformation(
          profileImageId: uploaded.id,
          profileImageUrl: uploaded.url,
        );
      }

      emit(const ProfileUpdateSuccess(null));
    } on Exception catch (e) {
      emit(ProfileUpdateError(e.toString()));
    }
  }

  Future<void> _onUpdateProviderService(
    UpdateProviderServiceEvent event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    final result = await updateUserRepo.updateProviderService(
      isActive: event.isActive,
      serviceCategoryId: event.serviceCategoryId,
      customServiceName: event.customServiceName,
      minorServices: [],
    );

    if (result.error != null) {
      emit(ProfileUpdateError(result.error!));
    } else {
      emit(ProfileUpdateSuccess(result.data));
    }
  }

  Future<void> _onUpdateProviderAddress(
    UpdateProviderAddressEvent event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    final result = await updateUserRepo.updateProviderAddress(
      addressData: event.addressData,
    );

    if (result.error != null) {
      emit(ProfileUpdateError(result.error!));
    } else {
      emit(ProfileUpdateSuccess(result.data));
    }
  }

  Future<void> _onUpdateBankAccount(
    UpdateBankAccountEvent event,
    Emitter<ProfileUpdateState> emit,
  ) async {
    emit(ProfileUpdateLoading());
    final result = await updateUserRepo.updateBankAccount(
      accountName: event.accountName,
      accountNumber: event.accountNumber,
      bankName: event.bankName,
      bankCode: event.bankCode,
    );

    if (result.error != null) {
      emit(ProfileUpdateError(result.error!));
    } else {
      emit(ProfileUpdateSuccess(result.data));
    }
  }
}
