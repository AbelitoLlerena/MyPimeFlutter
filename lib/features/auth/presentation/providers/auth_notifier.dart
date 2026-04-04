import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mypime/features/auth/domain/entities/auth_entity.dart';
import 'package:mypime/features/auth/domain/usecases/login_usecase.dart';
import 'package:mypime/features/auth/domain/usecases/signup_usecase.dart';
import 'package:mypime/core/auth/token_storage.dart';
import 'package:mypime/features/users/domain/enums/user_role_enum.dart';

class AuthNotifier extends StateNotifier<AsyncValue<AuthEntity?>> {
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

      await tokenStorage.saveToken(auth.accessToken);

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

      await tokenStorage.saveToken(auth.accessToken);

      return auth;
    });
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    state = const AsyncValue.loading();

    await tokenStorage.clear();
    state = const AsyncValue.data(null);
  }

  // 👇 getters tipo ChangeNotifier
  bool get isLoggedIn => state.value != null;
  UserRole? get role => state.value?.user.role;
}
