import '../domain/sync_action.dart';

abstract class SyncQueue {
  Future<void> add(SyncAction action);
  Future<List<SyncAction>> getPending();
  Future<void> remove(String id);
}