part of 'profile_update_bloc.dart';

sealed class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object?> get props => [];
}


final class UpdateUserInfoEvent extends ProfileUpdateEvent {
  const UpdateUserInfoEvent({
     this.fullName,
     this.phoneNumber,
    this.profileImageUrl,
    this.profileImageId,
  });
  final String? fullName;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? profileImageId;

  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    profileImageUrl,
    profileImageId,
  ];
}

final class UpdateProviderInfoEvent extends ProfileUpdateEvent {
  const UpdateProviderInfoEvent( {
     this.description,
     this.workingDays,
     this.openingHours,
     this.closingHours,
    this.activityStatus,
    this.fullName,
    this.phoneNumber,
    this.companyName,
    this.filePath,
    this.profileImageUrl,
    this.profileImageId,
    this.images,
  });
  final String? fullName;
  final String? phoneNumber;
  final String? companyName;
  final String? description;
  final List<String>? workingDays;
  final DateTime? openingHours;
  final DateTime? closingHours;
  final String? activityStatus;
  final String? filePath;
  final String? profileImageUrl;
  final String? profileImageId;
  final List<File>? images;


  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    companyName,
    description,
    workingDays,
    openingHours,
    closingHours,
    activityStatus,
    profileImageUrl,
    profileImageId,
  ];
}

class UpdateProfileImageEvent extends ProfileUpdateEvent {
  const UpdateProfileImageEvent({required this.filePath});
  final String filePath;
}


final class UpdateProviderServiceEvent extends ProfileUpdateEvent {
  const UpdateProviderServiceEvent({
  required this.isActive,
  required this.serviceCategoryId,
   this.customServiceName,
   this.minorServices, 
  });
   final bool isActive;
    final int serviceCategoryId;
    final String? customServiceName;
    final List<String>? minorServices;

  @override
  List<Object?> get props => [isActive, serviceCategoryId, customServiceName, minorServices];
}


final class UpdateProviderAddressEvent extends ProfileUpdateEvent {
  const UpdateProviderAddressEvent({
    required this.addressData,
  });
  final Map<String, dynamic> addressData;

  @override
  List<Object> get props => [addressData];
}

final class UpdateBankAccountEvent extends ProfileUpdateEvent {
  const UpdateBankAccountEvent({
    required this.accountName,
    required this.accountNumber,
    required this.bankName,
    required this.bankCode,
  });
  final String accountName;
  final String accountNumber;
  final String bankName;
  final String bankCode;

  @override
  List<Object> get props => [accountName, accountNumber, bankName, bankCode];
}
