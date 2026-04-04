import '../../features/users/domain/entities/user_entity.dart';
import '../../features/users/domain/enums/user_role_enum.dart';

class RoleGuard {
  static bool canAccess(UserRole role, UserEntity user) {
    return user.role == role;
  }
}