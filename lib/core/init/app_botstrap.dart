import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../sync/data/sync_action_model.dart';

class AppBootstrap {
  static Future<Isar> initIsar() async {
    final dir = await getApplicationDocumentsDirectory();

    final isar = await Isar.open(
      [
        SyncActionModelSchema,
      ],
      directory: dir.path,
    );

    return isar;
  }
}