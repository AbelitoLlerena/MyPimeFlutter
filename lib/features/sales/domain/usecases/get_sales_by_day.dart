import '../entities/sale_entity.dart';
import '../repositories/sales_repository.dart';

class GetSalesByDay {
  GetSalesByDay(this._repository);

  final SalesRepository _repository;

  Future<List<SaleEntity>> call(DateTime day) => _repository.listByDay(day);
}
