import 'package:mypime/features/auth/domain/entities/auth_entity.dart';
import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';

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