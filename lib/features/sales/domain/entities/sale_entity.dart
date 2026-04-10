class SaleLineEntity {
  const SaleLineEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  double get lineTotal => unitPrice * quantity;
}

class SaleEntity {
  const SaleEntity({
    required this.id,
    required this.createdAt,
    required this.total,
    required this.lines,
    this.paymentMethod,
    this.cashReceived,
    this.changeAmount,
    this.isLocalOnly = false,
  });

  final String id;
  final DateTime createdAt;
  final double total;
  final List<SaleLineEntity> lines;
  final String? paymentMethod;
  final double? cashReceived;
  final double? changeAmount;
  final bool isLocalOnly;
}
