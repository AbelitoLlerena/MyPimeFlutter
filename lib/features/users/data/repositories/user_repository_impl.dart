import 'package:isar/isar.dart';
import 'package:mypime/core/sync/domain/sync_queue.dart';
import 'package:mypime/core/sync/domain/sync_action.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';
import 'package:mypime/features/users/domain/repositories/user_repository.dart';
import 'package:mypime/features/users/data/models/user_model.dart';
import 'package:mypime/features/users/data/models/user_isar_model.dart';

class UserRepositoryImpl implements UserRepository {
  final Isar isar;
  final SyncQueue syncQueue;

  UserRepositoryImpl({
    required this.isar,
    required this.syncQueue,
  });

  @override
  Future<UserEntity?> create(UserModel payload) async {
    final entity = payload.toEntity();

    await isar.writeTxn(() async {
      await isar.userIsarModels.put(UserIsarModel.fromEntity(entity));
    });

    await syncQueue.add(SyncAction(
      id: entity.id,
      type: 'CREATE_USER',
      payload: payload.toJson(),
      createdAt: DateTime.now(),
    ));

    return entity;
  }

  @override
  Future<List<UserEntity>> findAll() async {
    final localUsers = await isar.userIsarModels.where().findAll();
    return localUsers.map((u) => u.toEntity()).toList();
  }

  @override
  Future<UserEntity?> findOne(String id) async {
    final user = await isar.userIsarModels.get(id.hashCode);
    return user?.toEntity();
  }

  @override
  Future<UserEntity?> findByName(String name) async {
    final user = await isar.userIsarModels.filter().nameEqualTo(name).findFirst();
    return user?.toEntity();
  }

  @override
  Future<void> deleteUser(String id) async {
    // 1. Eliminar optimista en Isar
    await isar.writeTxn(() async {
      await isar.userIsarModels.delete(id.hashCode);
    });

    // 2. Encolar acción
    await syncQueue.add(SyncAction(
      id: id,
      type: 'DELETE_USER',
      payload: { 'id': id },
      createdAt: DateTime.now(),
    ));
  }
}
