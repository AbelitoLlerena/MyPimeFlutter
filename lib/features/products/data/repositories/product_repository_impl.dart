import 'package:isar/isar.dart';
import 'package:mypime/features/products/data/models/product_isar_model.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';
import 'package:mypime/features/products/domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<ProductEntity>> getAll({String? categoryId}) async {
    final rows = await _isar.productIsarModels.where().findAll();
    var list = rows.map((r) => r.toEntity()).toList();
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    return list;
  }

  @override
  Future<ProductEntity> getById(String id) async {
    final row = await _isar.productIsarModels.get(id.hashCode);
    if (row == null) {
      throw StateError('Producto no encontrado: $id');
    }
    return row.toEntity();
  }

  @override
  Future<ProductEntity> create({
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool isActive = true,
  }) async {
    final id = 'prd-${DateTime.now().millisecondsSinceEpoch}';
    final model = ProductIsarModel()
      ..id = id
      ..name = name
      ..description = description
      ..sku = sku
      ..price = price
      ..categoryId = categoryId
      ..stock = stock
      ..minStock = minStock
      ..isActive = isActive;

    await _isar.writeTxn(() async {
      await _isar.productIsarModels.put(model);
    });
    return model.toEntity();
  }

  @override
  Future<ProductEntity> update(
    String id, {
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool? isActive,
  }) async {
    final existing = await _isar.productIsarModels.get(id.hashCode);
    if (existing == null) {
      throw StateError('Producto no encontrado: $id');
    }
    existing
      ..name = name
      ..description = description
      ..sku = sku
      ..price = price
      ..categoryId = categoryId
      ..stock = stock
      ..minStock = minStock
      ..isActive = isActive ?? existing.isActive;

    await _isar.writeTxn(() async {
      await _isar.productIsarModels.put(existing);
    });
    return existing.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await _isar.writeTxn(() async {
      await _isar.productIsarModels.delete(id.hashCode);
    });
  }
}
