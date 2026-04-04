import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/remote/user_remote_datasource.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remote;

  UserRepositoryImpl(this.remote);

  @override
  Future<List<UserEntity>> findAll() async {
    final models = await remote.getUsers();
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<UserEntity?> findOne(String id) async {
    final model = await remote.getUser(id);
    return model.toEntity();
  }

  @override
  Future<UserEntity?> findByName(String name) {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteUser(String id) async {
    await remote.deleteUser(id);
  }
}