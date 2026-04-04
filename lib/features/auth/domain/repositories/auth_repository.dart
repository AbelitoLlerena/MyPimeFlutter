import 'package:mypime/features/auth/domain/entities/auth_entity.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<AuthEntity> login({
    required String name,
    required String password,
  });

  Future<AuthEntity> signUp({
    required String name,
    required String password,
    required String role,
  });

  Future<UserEntity?> getCurrentUser();
}