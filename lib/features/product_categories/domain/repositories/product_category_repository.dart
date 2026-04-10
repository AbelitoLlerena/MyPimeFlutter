import '../entities/product_category_entity.dart';

abstract class ProductCategoryRepository {
  Future<List<ProductCategoryEntity>> getAll();
  Future<ProductCategoryEntity> getById(String id);
  Future<ProductCategoryEntity> create({
    required String name,
    String? description,
  });
  Future<ProductCategoryEntity> update(
    String id, {
    required String name,
    String? description,
  });
  Future<void> delete(String id);
}
