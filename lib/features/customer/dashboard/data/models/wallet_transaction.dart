import 'dart:convert';

import 'package:intl/intl.dart';

class WalletTransactionsData {
  WalletTransactionsData({
    required this.transactions,
    required this.pagination,
  });

  factory WalletTransactionsData.fromJson(Map<String, dynamic> json) {
    return WalletTransactionsData(
      transactions:
          (json['data'] as List<dynamic>)
              .map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>))
              .toList(),
      pagination: Pagination.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
  final List<WalletTransaction> transactions;
  final Pagination pagination;
}

class WalletTransaction {
  WalletTransaction({
    this.id,
    this.amount,
    this.currency,
    this.type,
    this.category,
    this.status,
    this.description,
    this.reference,
    this.gatewayReference,
    this.metadata,
    this.walletId,
    this.userId,
    this.providerId,
    this.balanceBefore,
    this.balanceAfter,
    this.processedAt,
    this.createdAt,
    this.updatedAt,
    this.serviceRequestId,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['id'] as int?,
      amount: json['amount']?.toString(),
      currency: json['currency'] as String?,
      type: json['type'] as String?,
      category: json['category'] as String?,
      status: json['status'] as String?,
      description: json['description'] as String?,
      reference: json['reference'] as String?,
      gatewayReference: json['gatewayReference'] as String?,
      metadata: _parseMetadata(json['metadata']),
      walletId: json['walletId'] as int?,
      userId: json['userId'] as int?,
      providerId: json['providerId'] as int?,
      balanceBefore: json['balanceBefore']?.toString(),
      balanceAfter: json['balanceAfter']?.toString(),
      processedAt:
          json['processedAt'] != null
              ? DateTime.tryParse(json['processedAt'].toString())
              : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
      serviceRequestId: json['serviceRequestId'] as int?,
    );
  }

  final int? id;
  final String? amount;
  final String? currency;
  final String? type;
  final String? category;
  final String? status;
  final String? description;
  final String? reference;
  final String? gatewayReference;
  final TransactionMetadata? metadata;
  final int? walletId;
  final int? userId;
  final int? providerId;
  final String? balanceBefore;
  final String? balanceAfter;
  final DateTime? processedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? serviceRequestId;

  static TransactionMetadata? _parseMetadata(dynamic raw) {
    if (raw == null) return null;

    try {
      if (raw is String) {
        return TransactionMetadata.fromJson(
          jsonDecode(raw) as Map<String, dynamic>,
        );
      }

      if (raw is Map<String, dynamic>) {
        return TransactionMetadata.fromJson(raw);
      }

      return null;
    } on Exception catch (_) {
      return null;
    }
  }
}

class TransactionMetadata {
  TransactionMetadata({
    this.walletId,
    this.userId,
    this.userType,
  });

  factory TransactionMetadata.fromJson(Map<String, dynamic> json) {
    return TransactionMetadata(
      walletId: json['walletId'] as int?,
      userId: json['userId'] as int?,
      userType: json['userType'] as String,
    );
  }
  final int? walletId;
  final int? userId;
  final String? userType;
}

class Pagination {
  Pagination({
    this.currentPage,
    this.totalPages,
    this.total,
    this.itemsPerPage,
    this.hasNextPage,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['currentPage'] as int,
      totalPages: json['totalPages'] as int,
      total: json['total'] as int,
      itemsPerPage: json['itemsPerPage'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPrev: json['hasPrev'] as bool,
    );
  }
  final int? currentPage;
  final int? totalPages;
  final int? total;
  final int? itemsPerPage;
  final bool? hasNextPage;
  final bool? hasPrev;
}

extension WalletTransactionUI on WalletTransaction {
  bool get isCredit => type == 'CREDIT';

  bool get isDebit => type == 'DEBIT';

  String get title {
    switch (category) {
      case 'WALLET_FUNDING':
        return 'Wallet Funding';
      case 'SERVICE_PAYMENT':
        return 'Service Payment';
      case 'REFUND':
        return 'Refund';
      default:
        return (description != null && description!.isNotEmpty)
            ? description!
            : 'Wallet Transaction';
    }
  }

  int get uiAmount => int.tryParse(amount ?? '0') ?? 0;

  String get uiDate {
    final dt = processedAt ?? createdAt;
    if (dt == null) return '';
    return _formatDate(dt);
  }

  static String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Today, ${_time(date)}';
    }
    if (diff.inDays == 1) {
      return 'Yesterday, ${_time(date)}';
    }

    String formatDate(DateTime date) {
      return DateFormat('MMM d, y - h:mma').format(date);
    }

    return formatDate(date);
    // 'Aug 27, 2025 - 5:16pm'
  }

  static String _time(DateTime d) {
    final hour = d.hour > 12 ? d.hour - 12 : d.hour;
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${d.minute.toString().padLeft(2, '0')} $period';
  }
}
