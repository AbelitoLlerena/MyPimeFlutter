import 'package:isar/isar.dart';
import 'package:mypime/core/auth/local_password.dart';
import 'package:mypime/features/product_categories/data/models/product_category_isar_model.dart';
import 'package:mypime/features/products/data/models/product_isar_model.dart';
import 'package:mypime/features/users/data/models/user_isar_model.dart';

/// Datos iniciales si faltan tablas vacías (solo dispositivo, sin servidor).
Future<void> seedLocalDatabaseIfEmpty(Isar isar) async {
  final hasUsers = await isar.userIsarModels.where().count() > 0;
  final hasCategories = await isar.productCategoryIsarModels.where().count() > 0;
  final hasProducts = await isar.productIsarModels.where().count() > 0;

  if (hasUsers && hasCategories && hasProducts) return;

  await isar.writeTxn(() async {
    if (!hasUsers) {
      final admin = UserIsarModel()
        ..id = '1'
        ..name = 'admin'
        ..role = 'ADMIN'
        ..passwordHash = hashLocalPassword('admin');
      await isar.userIsarModels.put(admin);
    }

    String? categoryIdForProducts;
    if (!hasCategories) {
      final cat = ProductCategoryIsarModel()
        ..id = 'cat-local-1'
        ..name = 'General'
        ..description = 'Categoría por defecto';
      await isar.productCategoryIsarModels.put(cat);
      categoryIdForProducts = cat.id;
    } else {
      final first = await isar.productCategoryIsarModels.where().findFirst();
      categoryIdForProducts = first?.id;
    }

    if (!hasProducts && categoryIdForProducts != null) {
      final cid = categoryIdForProducts;
      final p1 = ProductIsarModel()
        ..id = 'prd-local-1'
        ..name = 'Producto demo'
        ..description = 'Stock en tu dispositivo'
        ..sku = 'DEMO-1'
        ..price = 9.99
        ..categoryId = cid
        ..stock = 100
        ..minStock = 5
        ..isActive = true;
      final p2 = ProductIsarModel()
        ..id = 'prd-local-2'
        ..name = 'Artículo demo 2'
        ..sku = 'DEMO-2'
        ..price = 4.5
        ..categoryId = cid
        ..stock = 50
        ..minStock = 5
        ..isActive = true;
      await isar.productIsarModels.putAll([p1, p2]);
    }
  });
}
