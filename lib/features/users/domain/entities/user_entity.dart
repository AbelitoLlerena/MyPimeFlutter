import '../../domain/enums/user_role_enum.dart';

class UserEntity {
  final String id;
  final String name;
  final UserRole role;

  UserEntity({
    required this.id,
    required this.name,
    required this.role,
  });
}