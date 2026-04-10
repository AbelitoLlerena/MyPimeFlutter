import 'package:mypime/features/sales/domain/entities/sale_entity.dart';

class SaleModel {
  SaleModel({
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

  static DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.now();
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString()) ?? DateTime.now();
  }

  static double _parseDouble(dynamic raw) {
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '') ?? 0;
  }

  static int _parseInt(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '1') ?? 1;
  }

  factory SaleModel.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'] ?? json['items'] ?? json['details'];
    final lines = <SaleLineEntity>[];
    if (rawLines is List) {
      for (final e in rawLines) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        lines.add(
          SaleLineEntity(
            productId: m['productId']?.toString() ?? m['product_id']?.toString() ?? '',
            productName: m['productName']?.toString() ??
                m['name']?.toString() ??
                m['product']?['name']?.toString() ??
                'Producto',
            quantity: _parseInt(m['quantity'] ?? m['qty']),
            unitPrice: _parseDouble(m['unitPrice'] ?? m['unit_price'] ?? m['price']),
          ),
        );
      }
    }

    return SaleModel(
      id: json['id']?.toString() ?? '',
      createdAt: _parseDate(json['createdAt'] ?? json['created_at'] ?? json['date']),
      total: _parseDouble(json['total'] ?? json['amount']),
      lines: lines,
      paymentMethod: json['paymentMethod']?.toString() ?? json['payment_method']?.toString(),
      cashReceived: json['cashReceived'] != null || json['cash_received'] != null
          ? _parseDouble(json['cashReceived'] ?? json['cash_received'])
          : null,
      changeAmount: json['change'] != null || json['changeAmount'] != null
          ? _parseDouble(json['change'] ?? json['changeAmount'] ?? json['change_amount'])
          : null,
      isLocalOnly: json['isLocalOnly'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'total': total,
      'paymentMethod': paymentMethod,
      'cashReceived': cashReceived,
      'change': changeAmount,
      'isLocalOnly': isLocalOnly,
      'lines': [
        for (final l in lines)
          {
            'productId': l.productId,
            'productName': l.productName,
            'quantity': l.quantity,
            'unitPrice': l.unitPrice,
          },
      ],
    };
  }

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      createdAt: createdAt,
      total: total,
      lines: lines,
      paymentMethod: paymentMethod,
      cashReceived: cashReceived,
      changeAmount: changeAmount,
      isLocalOnly: isLocalOnly,
    );
  }
}
