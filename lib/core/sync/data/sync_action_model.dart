import 'package:isar/isar.dart';

part 'sync_action_model.g.dart';

@collection
class SyncActionModel {
  Id isarId = Isar.autoIncrement;

  @Index(unique: true)
  late String id;

  late String type;
  late String payloadJson;

  @Index()
  late DateTime createdAt;
}