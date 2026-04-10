import '../entities/product_category_entity.dart';
import '../repositories/product_category_repository.dart';

class UpdateProductCategory {
  UpdateProductCategory(this._repository);

  final ProductCategoryRepository _repository;

  Future<ProductCategoryEntity> call(
    String id, {
    required String name,
    String? description,
  }) {
    return _repository.update(id, name: name, description: description);
  }
}
