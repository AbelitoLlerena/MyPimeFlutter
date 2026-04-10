import '../entities/sale_entity.dart';
import '../repositories/sales_repository.dart';

class CreateSale {
  CreateSale(this._repository);

  final SalesRepository _repository;

  Future<SaleEntity> call({
    required List<SaleLineEntity> lines,
    required String paymentMethod,
    double? cashReceived,
  }) {
    return _repository.createSale(
      lines: lines,
      paymentMethod: paymentMethod,
      cashReceived: cashReceived,
    );
  }
}
