import '../domain/sync_action.dart';
import '../domain/sync_handler.dart';

class SyncExecutor {
  final Map<String, SyncHandler> handlers;

  SyncExecutor({required this.handlers});

  Future<void> execute(SyncAction action) async {
    final handler = handlers[action.type];

    if (handler == null) {
      throw Exception('No handler for ${action.type}');
    }

    await handler.handle(action.payload);
  }
}