
import 'dart:convert';

Wallet wwalletFromJson(String str) => Wallet.fromJson(json.decode(str) as Map<String, dynamic>);

String walletToJson(Wallet wallet) => json.encode(wallet.toJson());

class WalletResponse {

    WalletResponse({
        this.message,
        this.success,
        this.data,
    });

    factory WalletResponse.fromJson(Map<String, dynamic> json) => WalletResponse(
        message: json['message'] as String?,
        success: json['success'] as bool?,
        data: json['data'] == null ? null : Wallet.fromJson(json['data'] as Map<String, dynamic>),
    );
    final String? message;
    final bool? success;
    final Wallet? data;

    Map<String, dynamic> toJson() => {
        'message': message,
        'success': success,
        'data': data?.toJson(),
    };
}


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

    factory Wallet.fromJson(Map<String, dynamic> json) => Wallet(
        id: json['id'] as int,
        userId: json['userId'] as int,
        balance: json['balance']?.toDouble() as double,
        availableBalance: json['availableBalance'] as int,
        pendingBalance: json['pendingBalance']  as int,
        totalEarnings: json['totalEarnings'] as int,
        totalWithdrawn: json['totalWithdrawn'] as int,
        currency: json['currency'] as String,
        isActive: json['isActive']  as bool,
        createdAt: json['createdAt'] == null ? null : DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] == null ? null : DateTime.parse(json['updatedAt'] as String),
    );
    final int? id;
    final int? userId;
    final double? balance;
    final int? availableBalance;
    final int? pendingBalance;
    final int? totalEarnings;
    final int? totalWithdrawn;
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
