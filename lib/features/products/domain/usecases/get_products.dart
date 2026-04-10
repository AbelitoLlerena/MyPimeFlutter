import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProducts {
  GetProducts(this._repository);

  final ProductRepository _repository;

  Future<List<ProductEntity>> call({String? categoryId}) =>
      _repository.getAll(categoryId: categoryId);
}
