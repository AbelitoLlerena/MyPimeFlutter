import 'package:mypime/features/auth/domain/entities/auth_entity.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';
import 'package:mypime/features/users/domain/enums/user_role_enum.dart';

class AuthModel {
  final String accessToken;
  final Map<String, dynamic> user;

  AuthModel({
    required this.accessToken,
    required this.user,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    return AuthModel(
      accessToken: json['accessToken'] ?? json['access_token'],
      user: json['usersave'] ?? json['user'],
    );
  }

  AuthEntity toEntity() {
    final role = user['role'] == 'ADMIN'
        ? UserRole.admin
        : UserRole.seller;

    return AuthEntity(
      accessToken: accessToken,
      user: UserEntity(
        id: user['id'],
        name: user['name'],
        role: role,
      ),
    );
  }
}