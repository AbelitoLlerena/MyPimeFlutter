import 'dart:convert';
import 'package:isar/isar.dart';
import 'package:mypime/core/sync/domain/sync_queue.dart';
import '../domain/sync_action.dart';
import 'sync_action_model.dart';

class SyncQueueImpl implements SyncQueue {
  final Isar isar;

  SyncQueueImpl({required this.isar});

  @override
  Future<void> add(SyncAction action) async {
    final model = SyncActionModel()
      ..id = action.id
      ..type = action.type
      ..payloadJson = jsonEncode(action.payload)
      ..createdAt = action.createdAt;

    await isar.writeTxn(() async {
      await isar.syncActionModels.put(model);
    });
  }

  @override
  Future<List<SyncAction>> getPending() async {
    final models = await isar.syncActionModels.where().sortByCreatedAt().findAll();

    return models.map((m) {
      return SyncAction(
        id: m.id,
        type: m.type,
        payload: jsonDecode(m.payloadJson),
        createdAt: m.createdAt,
      );
    }).toList();
  }

  @override
  Future<void> remove(String id) async {
    final model = await isar.syncActionModels.filter().idEqualTo(id).findFirst();

    if (model != null) {
      await isar.writeTxn(() async {
        await isar.syncActionModels.delete(model.isarId);
      });
    }
  }
}