import '../entities/user_entity.dart';

abstract class UserRepository {
  Future<List<UserEntity>> findAll();
  Future<UserEntity?> findOne(String id);
  Future<UserEntity?> findByName(String name);
  Future<void> deleteUser(String id);
}