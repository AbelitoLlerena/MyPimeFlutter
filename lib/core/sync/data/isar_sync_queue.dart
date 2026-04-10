import 'package:isar/isar.dart';
import 'package:mypime/core/sync/data/sync_action_model.dart';
import 'package:mypime/core/sync/domain/sync_action.dart';
import 'package:mypime/core/sync/domain/sync_queue.dart';

class IsarSyncQueue implements SyncQueue {
  IsarSyncQueue(this._isar);

  final Isar _isar;

  @override
  Future<void> add(SyncAction action) async {
    final model = SyncActionModel.fromAction(action);
    await _isar.writeTxn(() async {
      await _isar.syncActionModels.put(model);
    });
  }
}
