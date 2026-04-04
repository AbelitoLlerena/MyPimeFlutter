import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<AuthEntity> call({
    required String name,
    required String password,
    required String role,
  }) {
    return repository.signUp(
      name: name,
      password: password,
      role: role,
    );
  }
}