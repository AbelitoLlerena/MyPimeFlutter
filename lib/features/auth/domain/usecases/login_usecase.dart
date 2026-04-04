import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<UserEntity> call({
    required String name,
    required String password,
  }) {
    return repository.login(
      name: name,
      password: password,
    );
  }
}