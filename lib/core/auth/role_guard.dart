import '../../domain/entities/user_entity.dart';
import '../../domain/enums/user_role_enum.dart';

class RoleGuard {
  static bool canAccess(UserRole role, UserEntity user) {
    return user.role == role;
  }
}