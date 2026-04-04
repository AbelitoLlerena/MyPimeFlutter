import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../../core/auth/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final TokenStorage storage;

  AuthRepositoryImpl(this.remote, this.storage);

  @override
  Future<AuthEntity> login({
    required String name,
    required String password,
  }) async {

    final model = await remote.login(name, password);

    final entity = model.toEntity();

    await storage.saveToken(entity.accessToken);
    return entity;
  }

  @override
  Future<AuthEntity> signUp({
    required String name,
    required String password,
    required String role,
  }) async {
    final model = await remote.signUp(name, password, role);

    final entity = model.toEntity();

    await storage.saveToken(entity.accessToken);

    return entity;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    // 🔥 versión simple (puedes mejorar luego con JWT decode)
    return null;
  }
}