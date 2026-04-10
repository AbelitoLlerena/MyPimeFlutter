import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class CreateProduct {
  CreateProduct(this._repository);

  final ProductRepository _repository;

  Future<ProductEntity> call({
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool isActive = true,
  }) {
    return _repository.create(
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
