import 'package:mypime/features/users/data/models/user_model.dart';

import '../repositories/user_repository.dart';

class CreateUser {
  final UserRepository repository;

  CreateUser(this.repository);

  Future<void> call(UserModel payload) {
    return repository.create(payload);
  }
}