import 'dart:convert';

class ProviderStats {

    ProviderStats({
        this.completedServicesCount,
        this.totalRevenue,
        this.currency,
    });

    factory ProviderStats.fromJson(Map<String, dynamic> json) => ProviderStats(
        completedServicesCount: json['completedServicesCount'] as int?,
        totalRevenue: json['totalRevenue'] as int?,
        currency: json['currency'] as String?,
    );

    factory ProviderStats.fromRawJson(String str) => ProviderStats.fromJson(json.decode(str) as Map<String, dynamic>);
    final int? completedServicesCount;
    final int? totalRevenue;
    final String? currency;

    String toRawJson() => json.encode(toJson());

    Map<String, dynamic> toJson() => {
        'completedServicesCount': completedServicesCount,
        'totalRevenue': totalRevenue,
        'currency': currency,
    };
}
