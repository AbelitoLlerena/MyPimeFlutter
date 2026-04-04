import 'package:mypime/features/users/domain/entities/user_entity.dart';

class AuthEntity {
  final String accessToken;
  final UserEntity user;

  AuthEntity({
    required this.accessToken,
    required this.user,
  });
}