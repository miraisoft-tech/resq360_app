
import 'dart:convert';

Wallet wwalletFromJson(String str) => Wallet.fromJson(json.decode(str) as Map<String, dynamic>);

String walletToJson(Wallet wallet) => json.encode(wallet.toJson());

// class WalletResponse {

//     WalletResponse({
//         this.message,
//         this.success,
//         this.data,
//     });

//     factory WalletResponse.fromJson(Map<String, dynamic> json) => WalletResponse(
//         message: json['message'] as String?,
//         success: json['success'] as bool?,
//         data: json['data'] == null ? null : Wallet.fromJson(json['data'] as Map<String, dynamic>),
//     );
//     final String? message;
//     final bool? success;
//     final Wallet? data;

//     Map<String, dynamic> toJson() => {
//         'message': message,
//         'success': success,
//         'data': data?.toJson(),
//     };
// }


class Wallet {
    Wallet({
        this.id,
        this.userId,
        this.balance,
        this.availableBalance,
        this.pendingBalance,
        this.totalEarnings,
        this.totalWithdrawn,
        this.currency,
        this.isActive,
        this.createdAt,
        this.updatedAt,
    });

factory Wallet.fromJson(Map<String, dynamic> json) {
    final data = json['data'];

    double toDouble(dynamic v) {
      if (v == null) return 0;
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0.0;
      return 0;
    }

    return Wallet(
      id: data['id'] as int?,
      userId: data['userId'] as int?,
      balance: toDouble(data['balance']),
      availableBalance: toDouble(data['availableBalance']),
      pendingBalance: toDouble(data['pendingBalance']),
      totalEarnings: toDouble(data['totalEarnings']),
      totalWithdrawn: toDouble(data['totalWithdrawn']),
      currency: data['currency'] as String?,
      isActive: data['isActive'] as bool?,
        createdAt: data['createdAt'] == null ? null : DateTime.parse(data['createdAt'] as String),
        updatedAt: data['updatedAt'] == null ? null : DateTime.parse(data['updatedAt'] as String),
    );
  }
 final int? id;
  final int? userId;
  final double? balance;
  final double? availableBalance;
  final double? pendingBalance;
  final double? totalEarnings;
  final double? totalWithdrawn;
  final String? currency;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

    Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'balance': balance,
        'availableBalance': availableBalance,
        'pendingBalance': pendingBalance,
        'totalEarnings': totalEarnings,
        'totalWithdrawn': totalWithdrawn,
        'currency': currency,
        'isActive': isActive,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
    };
}
