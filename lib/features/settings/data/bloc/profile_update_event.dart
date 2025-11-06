part of 'profile_update_bloc.dart';

sealed class ProfileUpdateEvent extends Equatable {
  const ProfileUpdateEvent();

  @override
  List<Object?> get props => [];
}

/// Update user info
final class UpdateUserInfoEvent extends ProfileUpdateEvent {
  const UpdateUserInfoEvent({
    required this.fullName,
    required this.phoneNumber,
    this.profileImageUrl,
    this.profileImageId,
  });
  final String fullName;
  final String phoneNumber;
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

/// Update provider info
final class UpdateProviderInfoEvent extends ProfileUpdateEvent {
  const UpdateProviderInfoEvent({
    required this.fullName,
    required this.phoneNumber,
    required this.companyName,
    required this.description,
    required this.workingDays,
    required this.openingHours,
    required this.closingHours,
    required this.activityStatus,
    this.filePath,
    this.profileImageUrl,
    this.profileImageId,
  });
  final String fullName;
  final String phoneNumber;
  final String companyName;
  final String description;
  final List<String> workingDays;
  final DateTime openingHours;
  final DateTime closingHours;
  final String activityStatus;
  final String? filePath;
  final String? profileImageUrl;
  final String? profileImageId;

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

/// Update provider address
final class UpdateProviderAddressEvent extends ProfileUpdateEvent {
  const UpdateProviderAddressEvent({
    required this.addressData,
  });
  final Map<String, dynamic> addressData;

  @override
  List<Object> get props => [addressData];
}

/// Update bank account info
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
