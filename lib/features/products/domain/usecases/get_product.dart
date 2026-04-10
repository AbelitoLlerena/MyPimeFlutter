import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class GetProduct {
  GetProduct(this._repository);

  final ProductRepository _repository;

  Future<ProductEntity> call(String id) => _repository.getById(id);
}
