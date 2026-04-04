import '../../domain/entities/user_entity.dart';
import '../../domain/enums/user_role_enum.dart';

class UserSession {
  final String token;
  final UserEntity user;

  UserSession({
    required this.token,
    required this.user,
  });

  bool get isAdmin => user.role == UserRole.admin;
}