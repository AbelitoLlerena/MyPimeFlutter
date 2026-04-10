import '../entities/product_category_entity.dart';
import '../repositories/product_category_repository.dart';

class GetProductCategory {
  GetProductCategory(this._repository);

  final ProductCategoryRepository _repository;

  Future<ProductCategoryEntity> call(String id) => _repository.getById(id);
}
