import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:mypime/features/sales/data/models/sale_model.dart';
import 'package:mypime/features/sales/domain/entities/sale_entity.dart';

part 'sale_isar_model.g.dart';

@collection
class SaleIsarModel {
  Id get isarId => id.hashCode;

  late String id;
  late DateTime createdAt;
  late double total;
  String? paymentMethod;
  double? cashReceived;
  double? changeAmount;
  late bool isLocalOnly;
  late String linesJson;

  SaleModel toModel() {
    final list = jsonDecode(linesJson) as List<dynamic>;
    final lines = <SaleLineEntity>[];
    for (final e in list) {
      final m = e as Map<String, dynamic>;
      lines.add(
        SaleLineEntity(
          productId: m['productId'] as String? ?? '',
          productName: m['productName'] as String? ?? '',
          quantity: (m['quantity'] as num?)?.toInt() ?? 1,
          unitPrice: (m['unitPrice'] as num?)?.toDouble() ?? 0,
        ),
      );
    }
    return SaleModel(
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

  static SaleIsarModel fromModel(SaleModel m) {
    final linesJson = jsonEncode([
      for (final l in m.lines)
        {
          'productId': l.productId,
          'productName': l.productName,
          'quantity': l.quantity,
          'unitPrice': l.unitPrice,
        },
    ]);
    return SaleIsarModel()
      ..id = m.id
      ..createdAt = m.createdAt
      ..total = m.total
      ..paymentMethod = m.paymentMethod
      ..cashReceived = m.cashReceived
      ..changeAmount = m.changeAmount
      ..isLocalOnly = m.isLocalOnly
      ..linesJson = linesJson;
  }
}
