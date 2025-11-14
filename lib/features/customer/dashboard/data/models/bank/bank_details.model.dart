import 'dart:convert';

class BankDetails {

    BankDetails({
        this.accountName,
        this.accountNumber,
        this.bankName,
        this.bankCode,
        this.currency,
        this.isDefault,
    });

    factory BankDetails.fromRawJson(String str) => BankDetails.fromJson(json.decode(str) as Map<String, dynamic>);

    factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
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
