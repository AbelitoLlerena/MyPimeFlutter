import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';

class SignUpUseCase {
  final AuthRepository repository;

  SignUpUseCase(this.repository);

  Future<UserEntity> call({
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