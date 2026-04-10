import '../repositories/product_category_repository.dart';

class DeleteProductCategory {
  DeleteProductCategory(this._repository);

  final ProductCategoryRepository _repository;

  Future<void> call(String id) => _repository.delete(id);
}
