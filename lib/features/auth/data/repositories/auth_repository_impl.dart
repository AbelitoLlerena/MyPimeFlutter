import 'package:isar/isar.dart';
import 'package:mypime/core/auth/local_password.dart';
import 'package:mypime/core/auth/token_storage.dart';
import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';
import 'package:mypime/features/users/data/models/user_isar_model.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._isar, this.storage);

  final Isar _isar;
  final TokenStorage storage;

  @override
  Future<UserEntity> login({
    required String name,
    required String password,
  }) async {
    final trimmed = name.trim();
    final u = await _isar.userIsarModels
        .filter()
        .nameEqualTo(trimmed)
        .findFirst();
    if (u == null) {
      throw Exception('Usuario o contraseña incorrectos');
    }
    if (u.passwordHash.isEmpty ||
        !verifyLocalPassword(password, u.passwordHash)) {
      throw Exception('Usuario o contraseña incorrectos');
    }
    await storage.saveToken('local_${u.id}');
    await storage.saveUser(u.toEntity());
    return u.toEntity();
  }

  @override
  Future<UserEntity> signUp({
    required String name,
    required String password,
    required String role,
  }) async {
    final trimmed = name.trim();
    final exists = await _isar.userIsarModels
        .filter()
        .nameEqualTo(trimmed)
        .findFirst();
    if (exists != null) {
      throw Exception('El usuario ya existe');
    }
    final id = 'u-${DateTime.now().millisecondsSinceEpoch}';
    final r = role.toUpperCase();
    final model = UserIsarModel()
      ..id = id
      ..name = trimmed
      ..role = r == 'ADMIN' ? 'ADMIN' : 'SELLER'
      ..passwordHash = hashLocalPassword(password);

    await _isar.writeTxn(() async {
      await _isar.userIsarModels.put(model);
    });

    await storage.saveToken('local_$id');
    await storage.saveUser(model.toEntity());
    return model.toEntity();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = await storage.getToken();
    if (token == null || token.isEmpty) return null;
    final user = await storage.getUser();
    if (user == null) {
      await storage.clear();
      return null;
    }
    return user;
  }
}
