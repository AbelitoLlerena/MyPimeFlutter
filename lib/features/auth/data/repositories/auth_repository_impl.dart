import 'package:mypime/core/auth/token_storage.dart';
import 'package:mypime/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';


class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage storage;

  AuthRepositoryImpl(this.remote, this.storage);

  @override
  Future<UserEntity> login({
    required String name,
    required String password,
  }) async {

    final model = await remote.login(name, password);

    final entity = model.toEntity();

    await storage.saveToken(entity.accessToken);
    return entity.user;
  }

  @override
  Future<UserEntity> signUp({
    required String name,
    required String password,
    required String role,
  }) async {
    final model = await remote.signUp(name, password, role);

    final entity = model.toEntity();

    await storage.saveToken(entity.accessToken);

    return entity.user;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // 🔥 versión simple (puedes mejorar luego con JWT decode)
    return null;
  }
}