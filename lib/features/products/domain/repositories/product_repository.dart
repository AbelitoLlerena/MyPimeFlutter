import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getAll({String? categoryId});
  Future<ProductEntity> getById(String id);
  Future<ProductEntity> create({
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool isActive = true,
  });
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
  });
  Future<void> delete(String id);
}
