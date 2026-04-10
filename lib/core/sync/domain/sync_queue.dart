import 'sync_action.dart';

abstract class SyncQueue {
  Future<void> add(SyncAction action);
}
