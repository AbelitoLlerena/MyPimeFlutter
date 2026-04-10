import '../entities/sale_entity.dart';

abstract class SalesRepository {
  Future<SaleEntity> createSale({
    required List<SaleLineEntity> lines,
    required String paymentMethod,
    double? cashReceived,
  });

  Future<List<SaleEntity>> listByDay(DateTime day);
}
