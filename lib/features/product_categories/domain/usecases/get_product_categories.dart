import '../entities/product_category_entity.dart';
import '../repositories/product_category_repository.dart';

class GetProductCategories {
  GetProductCategories(this._repository);

  final ProductCategoryRepository _repository;

  Future<List<ProductCategoryEntity>> call() => _repository.getAll();
}
