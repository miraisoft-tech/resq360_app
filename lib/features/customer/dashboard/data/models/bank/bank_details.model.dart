import 'dart:convert';

class BankDetails {

    BankDetails({
        this.accountName,
        this.accountNumber,
        this.bankName,
        this.bankCode,
        this.routingNumber,
        this.swiftCode,
        this.currency,
        this.isDefault,
    });

    factory BankDetails.fromRawJson(String str) => BankDetails.fromJson(json.decode(str) as Map<String, dynamic>);

    factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
        accountName: json['accountName'] as String?,
        accountNumber: json['accountNumber'] as String?,
        bankName: json['bankName'] as String?,
        bankCode: json['bankCode'] as String?,
        routingNumber: json['routingNumber'] as String?,
        swiftCode: json['swiftCode'] as String?,
        currency: json['currency'] as String?,
        isDefault: json['isDefault'] as bool?,
    );
    final String? accountName;
    final String? accountNumber;
    final String? bankName;
    final String? bankCode;
    final String? routingNumber;
    final String? swiftCode;
    final String? currency;
    final bool? isDefault;

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        'accountName': accountName,
        'accountNumber': accountNumber,
        'bankName': bankName,
        'bankCode': bankCode,
        'routingNumber': routingNumber,
        'swiftCode': swiftCode,
        'currency': currency,
        'isDefault': isDefault,
    };
}
