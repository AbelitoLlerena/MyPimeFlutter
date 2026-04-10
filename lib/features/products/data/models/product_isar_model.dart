import 'package:isar/isar.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';

part 'product_isar_model.g.dart';

@collection
class ProductIsarModel {
  Id get isarId => id.hashCode;

  late String id;
  late String name;
  String? description;
  String? sku;
  late double price;
  late String categoryId;
  int? stock;
  int? minStock;
  late bool isActive;

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      sku: sku,
      price: price,
      categoryId: categoryId,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
  }

  static ProductIsarModel fromEntity(ProductEntity e) {
    return ProductIsarModel()
      ..id = e.id
      ..name = e.name
      ..description = e.description
      ..sku = e.sku
      ..price = e.price
      ..categoryId = e.categoryId
      ..stock = e.stock
      ..minStock = e.minStock
      ..isActive = e.isActive;
  }
}
