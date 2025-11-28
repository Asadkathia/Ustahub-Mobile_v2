class AddFundsResponse {
  final bool status;
  final String message;
  final double walletBalance;

  AddFundsResponse({
    required this.status,
    required this.message,
    required this.walletBalance,
  });

  factory AddFundsResponse.fromJson(Map<String, dynamic> json) {
    return AddFundsResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      walletBalance: double.tryParse(json['wallet_balance'].toString()) ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'message': message};
  }
}

// Wallet Balance Response Model
class WalletBalanceResponse {
  final bool status;
  final String walletBalance;
  final List<WalletTransaction> transactions;

  WalletBalanceResponse({
    required this.status,
    required this.walletBalance,
    required this.transactions,
  });

  factory WalletBalanceResponse.fromJson(Map<String, dynamic> json) {
    return WalletBalanceResponse(
      status: json['status'] ?? false,
      walletBalance: json['wallet_balance']?.toString() ?? '0.00',
      transactions:
          (json['transactions'] as List<dynamic>?)
              ?.map(
                (e) => WalletTransaction.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'wallet_balance': walletBalance,
      'transactions': transactions.map((e) => e.toJson()).toList(),
    };
  }

  // Helper methods
  double get balanceAsDouble => double.tryParse(walletBalance) ?? 0.0;
  String get formattedBalance => balanceAsDouble.toStringAsFixed(0);
}

// Wallet Transaction Model
class WalletTransaction {
  final String id;
  final String walletId;
  final String transactionId;
  final String openingBalance;
  final String amount;
  final String closingBalance;
  final String type;
  final String status;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletTransaction({
    required this.id,
    required this.walletId,
    required this.transactionId,
    required this.openingBalance,
    required this.amount,
    required this.closingBalance,
    required this.type,
    required this.status,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return WalletTransaction(
      id: json['id']?.toString() ?? '',
      walletId: json['wallet_id']?.toString() ?? '',
      transactionId: json['transaction_id']?.toString() ?? '',
      openingBalance: json['opening_balance']?.toString() ?? '0.00',
      amount: json['amount']?.toString() ?? '0.00',
      closingBalance: json['closing_balance']?.toString() ?? '0.00',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'transaction_id': transactionId,
      'opening_balance': openingBalance,
      'amount': amount,
      'closing_balance': closingBalance,
      'type': type,
      'status': status,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  double get amountAsDouble => double.tryParse(amount) ?? 0.0;
  double get openingBalanceAsDouble => double.tryParse(openingBalance) ?? 0.0;
  double get closingBalanceAsDouble => double.tryParse(closingBalance) ?? 0.0;

  String get formattedAmount => amountAsDouble.toStringAsFixed(0);
  String get formattedOpeningBalance =>
      openingBalanceAsDouble.toStringAsFixed(0);
  String get formattedClosingBalance =>
      closingBalanceAsDouble.toStringAsFixed(0);

  bool get isCredit => type.toLowerCase() == 'credit';
  bool get isDebit => type.toLowerCase() == 'debit';
  bool get isCompleted => status.toLowerCase() == 'completed';

  String get displayAmount =>
      isCredit ? '+$formattedAmount' : '-$formattedAmount';

  String get formattedDate {
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;

    if (difference == 0) {
      return 'Today, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    } else if (difference == 1) {
      return 'Yesterday';
    } else {
      return '${createdAt.day} ${_getMonthName(createdAt.month)}, ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  String get transactionInitials {
    if (isCredit) {
      return 'CR';
    } else {
      return 'DR';
    }
  }
}

class WalletData {
  final String id;
  final String userId;
  final double balance;
  final String transactionType;
  final double amount;
  final DateTime createdAt;
  final DateTime updatedAt;

  WalletData({
    required this.id,
    required this.userId,
    required this.balance,
    required this.transactionType,
    required this.amount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WalletData.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return WalletData(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0.0,
      transactionType: json['transaction_type']?.toString() ?? '',
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'balance': balance,
      'transaction_type': transactionType,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Helper methods
  String get formattedBalance => balance.toStringAsFixed(0);
  String get formattedAmount => amount.toStringAsFixed(0);
  bool get isCredit => transactionType.toLowerCase() == 'credit';
  bool get isDebit => transactionType.toLowerCase() == 'debit';

  // Copy with method for immutable updates
  WalletData copyWith({
    String? id,
    String? userId,
    double? balance,
    String? transactionType,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return WalletData(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      transactionType: transactionType ?? this.transactionType,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
