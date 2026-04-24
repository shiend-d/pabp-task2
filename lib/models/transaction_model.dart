class TransactionItem {
  final int id;
  final int transactionId;
  final int medicineId;
  final String medicineName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  TransactionItem({
    required this.id,
    required this.transactionId,
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as int,
      transactionId: json['transaction_id'] as int,
      medicineId: json['medicine_id'] as int,
      medicineName: json['medicine_name'] as String,
      quantity: json['quantity'] as int,
      unitPrice: (json['unit_price'] as num).toDouble(),
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }
}

class Transaction {
  final int id;
  final String? userId;
  final double totalAmount;
  final double cashReceived;
  final double changeAmount;
  final int itemsCount;
  final DateTime createdAt;
  final List<TransactionItem>? items;

  Transaction({
    required this.id,
    this.userId,
    required this.totalAmount,
    required this.cashReceived,
    required this.changeAmount,
    required this.itemsCount,
    required this.createdAt,
    this.items,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    List<TransactionItem>? items;
    if (json['transaction_items'] != null) {
      items = (json['transaction_items'] as List)
          .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return Transaction(
      id: json['id'] as int,
      userId: json['user_id'] as String?,
      totalAmount: (json['total_amount'] as num).toDouble(),
      cashReceived: (json['cash_received'] as num).toDouble(),
      changeAmount: (json['change_amount'] as num).toDouble(),
      itemsCount: json['items_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      items: items,
    );
  }
}
