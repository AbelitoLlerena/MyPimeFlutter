import 'package:isar/isar.dart';
import 'package:mypime/features/users/data/models/user_isar_model.dart';
import 'package:path_provider/path_provider.dart';

class AppBootstrap {
  static Future<Isar> initIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [
        UserIsarModelSchema,
      ],
      directory: dir.path,
    );

    return isar;
  }
}