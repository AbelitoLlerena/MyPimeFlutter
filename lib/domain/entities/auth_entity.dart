import 'user_entity.dart';

class AuthEntity {
  final String accessToken;
  final UserEntity user;

  AuthEntity({
    required this.accessToken,
    required this.user,
  });
}