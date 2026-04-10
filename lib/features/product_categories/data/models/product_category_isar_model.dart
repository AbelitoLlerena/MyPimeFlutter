import 'package:isar/isar.dart';
import 'package:mypime/features/product_categories/domain/entities/product_category_entity.dart';

part 'product_category_isar_model.g.dart';

@collection
class ProductCategoryIsarModel {
  Id get isarId => id.hashCode;

  late String id;
  late String name;
  String? description;

  ProductCategoryEntity toEntity() {
    return ProductCategoryEntity(
      id: id,
      name: name,
      description: description,
    );
  }

  static ProductCategoryIsarModel fromEntity(ProductCategoryEntity e) {
    return ProductCategoryIsarModel()
      ..id = e.id
      ..name = e.name
      ..description = e.description;
  }
}
