import 'package:mypime/features/users/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login({
    required String name,
    required String password,
  });

  Future<UserEntity> signUp({
    required String name,
    required String password,
    required String role,
  });

  Future<UserEntity?> getCurrentUser();
}