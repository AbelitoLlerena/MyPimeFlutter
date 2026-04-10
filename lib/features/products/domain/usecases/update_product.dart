import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProduct {
  UpdateProduct(this._repository);

  final ProductRepository _repository;

  Future<ProductEntity> call(
    String id, {
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool? isActive,
  }) {
    return _repository.update(
      id,
      name: name,
      description: description,
      sku: sku,
      price: price,
      categoryId: categoryId,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
  }
}
