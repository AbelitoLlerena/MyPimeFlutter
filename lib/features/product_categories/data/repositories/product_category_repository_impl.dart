import 'package:isar/isar.dart';
import 'package:mypime/features/product_categories/data/models/product_category_isar_model.dart';
import 'package:mypime/features/products/data/models/product_isar_model.dart';
import 'package:mypime/features/product_categories/domain/entities/product_category_entity.dart';
import 'package:mypime/features/product_categories/domain/repositories/product_category_repository.dart';

class ProductCategoryRepositoryImpl implements ProductCategoryRepository {
  ProductCategoryRepositoryImpl(this._isar);

  final Isar _isar;

  @override
  Future<List<ProductCategoryEntity>> getAll() async {
    final rows = await _isar.productCategoryIsarModels.where().findAll();
    return rows.map((r) => r.toEntity()).toList();
  }

  @override
  Future<ProductCategoryEntity> getById(String id) async {
    final row = await _isar.productCategoryIsarModels.get(id.hashCode);
    if (row == null) {
      throw StateError('Categoría no encontrada: $id');
    }
    return row.toEntity();
  }

  @override
  Future<ProductCategoryEntity> create({
    required String name,
    String? description,
  }) async {
    final id = 'cat-${DateTime.now().millisecondsSinceEpoch}';
    final model = ProductCategoryIsarModel()
      ..id = id
      ..name = name
      ..description = description;

    await _isar.writeTxn(() async {
      await _isar.productCategoryIsarModels.put(model);
    });
    return model.toEntity();
  }

  @override
  Future<ProductCategoryEntity> update(
    String id, {
    required String name,
    String? description,
  }) async {
    final existing = await _isar.productCategoryIsarModels.get(id.hashCode);
    if (existing == null) {
      throw StateError('Categoría no encontrada: $id');
    }
    existing
      ..name = name
      ..description = description;

    await _isar.writeTxn(() async {
      await _isar.productCategoryIsarModels.put(existing);
    });
    return existing.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    final products = await _isar.productIsarModels
        .filter()
        .categoryIdEqualTo(id)
        .findAll();
    if (products.isNotEmpty) {
      throw StateError(
        'No se puede eliminar: hay ${products.length} producto(s) en esta categoría',
      );
    }
    await _isar.writeTxn(() async {
      await _isar.productCategoryIsarModels.delete(id.hashCode);
    });
  }
}
