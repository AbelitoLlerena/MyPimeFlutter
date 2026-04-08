import 'package:mypime/features/users/data/models/user_model.dart';

import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> create(UserModel payload);
  Future<List<UserEntity>> findAll();
  Future<UserEntity?> findOne(String id);
  Future<UserEntity?> findByName(String name);
  Future<void> deleteUser(String id);
}