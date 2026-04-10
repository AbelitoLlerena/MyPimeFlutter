import 'package:isar/isar.dart';
import 'package:mypime/core/auth/session_isar_model.dart';
import 'package:mypime/core/init/app_seed.dart';
import 'package:mypime/core/sync/data/sync_action_model.dart';
import 'package:mypime/features/product_categories/data/models/product_category_isar_model.dart';
import 'package:mypime/features/products/data/models/product_isar_model.dart';
import 'package:mypime/features/sales/data/models/sale_isar_model.dart';
import 'package:mypime/features/users/data/models/user_isar_model.dart';
import 'package:path_provider/path_provider.dart';

class AppBootstrap {
  static Future<Isar> initIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [
        SyncActionModelSchema,
        UserIsarModelSchema,
        ProductCategoryIsarModelSchema,
        ProductIsarModelSchema,
        SessionIsarModelSchema,
        SaleIsarModelSchema,
      ],
      directory: dir.path,
      name: 'mypime_pos_db',
    );

    await seedLocalDatabaseIfEmpty(isar);

    return isar;
  }
}
