import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/domain/usecases/login_usecase.dart';
import 'package:mypime/features/auth/domain/usecases/signup_usecase.dart';
import 'package:mypime/core/auth/token_storage.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';

class AuthNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final TokenStorage tokenStorage;

  AuthNotifier({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.tokenStorage,
  }) : super(const AsyncValue.data(null));

  // 🔐 LOGIN
  Future<void> login({
    required String name,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final auth = await loginUseCase(
        name: name,
        password: password,
      );

      return auth;
    });
  }

  // 📝 SIGN UP
  Future<void> signUp({
    required String name,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();

    state = await AsyncValue.guard(() async {
      final auth = await signUpUseCase(
        name: name,
        password: password,
        role: role,
      );

      return auth;
    });
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    state = const AsyncValue.loading();

    await tokenStorage.clear();
    state = const AsyncValue.data(null);
  }
}
