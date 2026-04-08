import 'package:isar/isar.dart';
import 'package:mypime/core/sync/application/sync_executor.dart';
import 'package:mypime/core/sync/application/sync_service.dart';
import 'package:mypime/core/sync/data/sync_queue_impl.dart';
import 'package:mypime/core/sync/domain/sync_handler.dart';
import 'package:mypime/core/sync/domain/sync_queue.dart';
import 'package:riverpod/riverpod.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('Isar must be initialized in main');
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  final isar = ref.watch(isarProvider);
  return SyncQueueImpl(isar: isar);
});

final syncExecutorProvider = Provider<SyncExecutor>((ref) {
  final handlers = <SyncHandler>[
    // ref.watch(deleteUserHandlerProvider),
    // ref.watch(createUserHandlerProvider),
  ];

  return SyncExecutor(
    handlers: {
      for (final h in handlers) h.type: h,
    },
  );
});

final syncServiceProvider = Provider<SyncService>((ref) {
  return SyncService(
    queue: ref.watch(syncQueueProvider),
    executor: ref.watch(syncExecutorProvider),
  );
});