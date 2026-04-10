import 'package:isar/isar.dart';
import 'package:mypime/features/products/domain/repositories/product_repository.dart';
import 'package:mypime/features/sales/data/models/sale_isar_model.dart';
import 'package:mypime/features/sales/data/models/sale_model.dart';
import 'package:mypime/features/sales/domain/entities/sale_entity.dart';
import 'package:mypime/features/sales/domain/repositories/sales_repository.dart';

class SalesRepositoryImpl implements SalesRepository {
  SalesRepositoryImpl(this._isar, this._products);

  final Isar _isar;
  final ProductRepository _products;

  @override
  Future<SaleEntity> createSale({
    required List<SaleLineEntity> lines,
    required String paymentMethod,
    double? cashReceived,
  }) async {
    for (final line in lines) {
      final p = await _products.getById(line.productId);
      final current = p.stock ?? 0;
      final next = current - line.quantity;
      await _products.update(
        p.id,
        name: p.name,
        description: p.description,
        sku: p.sku,
        price: p.price,
        categoryId: p.categoryId,
        stock: next < 0 ? 0 : next,
        minStock: p.minStock,
        isActive: p.isActive,
      );
    }

    final total = lines.fold<double>(0, (s, l) => s + l.lineTotal);
    final change = (cashReceived != null) ? (cashReceived - total) : null;
    final model = SaleModel(
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      total: total,
      lines: lines,
      paymentMethod: paymentMethod,
      cashReceived: cashReceived,
      changeAmount: change,
      isLocalOnly: true,
    );
    final row = SaleIsarModel.fromModel(model);
    await _isar.writeTxn(() async {
      await _isar.saleIsarModels.put(row);
    });
    return model.toEntity();
  }

  @override
  Future<List<SaleEntity>> listByDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = start.add(const Duration(days: 1));
    final rows = await _isar.saleIsarModels
        .filter()
        .createdAtBetween(start, end, includeUpper: false)
        .findAll();
    final entities = rows.map((r) => r.toModel().toEntity()).toList();
    entities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return entities;
  }
}
