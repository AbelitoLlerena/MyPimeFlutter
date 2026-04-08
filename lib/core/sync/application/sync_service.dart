import 'package:mypime/core/sync/domain/sync_queue.dart';
import 'sync_executor.dart';

class SyncService {
  final SyncQueue queue;
  final SyncExecutor executor;

  bool _isProcessing = false;

  SyncService({
    required this.queue,
    required this.executor,
  });

  Future<void> processQueue() async {
    if (_isProcessing) return;

    _isProcessing = true;

    try {
      final actions = await queue.getPending();

      for (final action in actions) {
        try {
          await executor.execute(action);
          await queue.remove(action.id);
        } catch (e) {
          break;
        }
      }
    } finally {
      _isProcessing = false;
    }
  }
}