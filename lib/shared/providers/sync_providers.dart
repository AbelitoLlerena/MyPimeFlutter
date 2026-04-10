import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:mypime/core/sync/data/isar_sync_queue.dart';
import 'package:mypime/core/sync/domain/sync_queue.dart';
import 'package:mypime/features/users/data/repositories/user_repository_impl.dart';
import 'package:mypime/features/users/domain/repositories/user_repository.dart';

final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError('isarProvider debe inyectarse desde main');
});

final syncQueueProvider = Provider<SyncQueue>((ref) {
  return IsarSyncQueue(ref.watch(isarProvider));
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    isar: ref.watch(isarProvider),
    syncQueue: ref.watch(syncQueueProvider),
  );
});
