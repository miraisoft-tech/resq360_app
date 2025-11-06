import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:resq360/__lib.dart';
import 'package:resq360/core/services/auth.local.repo.dart';
import 'package:resq360/core/services/upload_service.dart';
import 'package:resq360/features/customer/authentication/data/models/auth/upload_response.model.dart';
import 'package:resq360/features/settings/data/service/update_user_repo.dart';

part 'profile_update_event.dart';
part 'profile_update_state.dart';

final UpdateUserRepo updateUserRepo = UpdateUserRepo();
final UploadService uploadService = UploadService.instance;


class ProfileUpdateBloc extends Bloc<ProfileUpdateEvent, ProfileUpdateState> {
  ProfileUpdateBloc() : super(ProfileUpdateInitial()) {
    on<UpdateUserInfoEvent>(_onUpdateUserInfo);
    on<UpdateProviderInfoEvent>(_onUpdateProviderInfo);
    on<UpdateProviderAddressEvent>(_onUpdateProviderAddress);
    on<UpdateBankAccountEvent>(_onUpdateBankAccount);
  }

  /// Handles user info update.
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

  /// Handles provider info update.
Future<void> _onUpdateProviderInfo(
  UpdateProviderInfoEvent event,
  Emitter<ProfileUpdateState> emit,
) async {
  emit(ProfileUpdateLoading());

  try {
    // Step 1: Upload provider image(s)
    UploadResponse? uploadedImage;

    if (event.filePath != null && event.filePath!.isNotEmpty) {
      final uploadResult = await uploadService.uploadSingle(
        filePath: event.filePath!,
      );

      if (uploadResult.error != null) {
        emit(ProfileUpdateError(uploadResult.error!));
        return;
      }

      uploadedImage = uploadResult.data;
      log('Uploaded image: ${uploadedImage?.id} / ${uploadedImage?.url}');
    }

     final provider = await AuthLocalRepo.instance.getProviderCredentials();
      if (provider == null) {
        log('No user');
      }

    // Step 2: Update provider info
    final result = await updateUserRepo.updateProviderInformation(
      fullName: provider?.user?.fullName ?? '',
      phoneNumber: provider?.user?.phoneNumber ?? '',
      companyName: provider?.user?.companyName ?? '',
      description: event.description,
      workingDays: event.workingDays,
      openingHours: event.openingHours,
      closingHours: event.closingHours,
      activityStatus: 'online',
      profileImageUrl: uploadedImage?.url,
      profileImageId: uploadedImage?.id,
    );

    // Step 3: Emit state based on result
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

  /// Handles provider address update.
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

  /// Handles bank account update.
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
