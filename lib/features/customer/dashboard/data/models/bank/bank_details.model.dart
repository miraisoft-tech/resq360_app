import 'dart:convert';

class BankRequestDetails {

    BankRequestDetails({
        this.accountName,
        this.accountNumber,
        this.bankName,
        this.bankCode,
        this.currency,
        this.isDefault,
    });

    factory BankRequestDetails.fromRawJson(String str) => BankRequestDetails.fromJson(json.decode(str) as Map<String, dynamic>);

    factory BankRequestDetails.fromJson(Map<String, dynamic> json) => BankRequestDetails(
        accountName: json['accountName'] as String?,
        accountNumber: json['accountNumber'] as String?,
        bankName: json['bankName'] as String?,
        bankCode: json['bankCode'] as String?,
        currency: json['currency'] as String?,
        isDefault: json['isDefault'] as bool?,
    );
    final String? accountName;
    final String? accountNumber;
    final String? bankName;
    final String? bankCode;
    final String? currency;
    final bool? isDefault;

    Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'bankCode': bankCode,
        'currency': currency,
        'isDefault': isDefault,
    };
}


class BankDetails {
  BankDetails({
    this.id,
    this.accountName,
    this.accountNumber,
    this.bankName,
    this.bankCode,
    this.currency,
    this.isVerified,
    this.isDefault,
    this.recipientCode,
    this.providerId,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        id: json['id'] as int?,
        accountName: json['accountName'] as String?,
        accountNumber: json['accountNumber'] as String?,
        bankName: json['bankName'] as String?,
        bankCode: json['bankCode'] as String?,
        currency: json['currency'] as String?,
        isVerified: json['isVerified'] as bool?,
        isDefault: json['isDefault'] as bool?,
        recipientCode: json['recipientCode'] as String?,
        providerId: json['providerId'] as int?,
        userId: json['userId'] as int?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );

  factory BankDetails.fromRawJson(String str) =>
      BankDetails.fromJson(json.decode(str) as Map<String, dynamic>);

  final int? id;
  final String? accountName;
  final String? accountNumber;
  final String? bankName;
  final String? bankCode;
  final String? currency;
  final bool? isVerified;
  final bool? isDefault;
  final String? recipientCode;
  final int? providerId;
  final int? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'bankCode': bankCode,
        'currency': currency,
        'isVerified': isVerified,
        'isDefault': isDefault,
        'recipientCode': recipientCode,
        'providerId': providerId,
        'userId': userId,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
