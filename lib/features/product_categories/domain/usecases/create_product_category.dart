import '../entities/product_category_entity.dart';
import '../repositories/product_category_repository.dart';

class CreateProductCategory {
  CreateProductCategory(this._repository);

  final ProductCategoryRepository _repository;

  Future<ProductCategoryEntity> call({
    required String name,
    String? description,
  }) {
    return _repository.create(name: name, description: description);
  }
}
