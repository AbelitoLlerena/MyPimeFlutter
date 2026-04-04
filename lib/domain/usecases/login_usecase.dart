import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<AuthEntity> call({
    required String name,
    required String password,
  }) {
    return repository.login(
      name: name,
      password: password,
    );
  }
}