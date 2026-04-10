import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';
import 'package:mypime/features/auth/domain/usecases/login_usecase.dart';
import 'package:mypime/features/auth/domain/usecases/signup_usecase.dart';
import 'package:mypime/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';
import 'package:mypime/shared/providers/sync_providers.dart';
import 'package:mypime/shared/providers/token_storage.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(isarProvider),
    ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});

final authStateNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserEntity?>>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    authRepository: ref.watch(authRepositoryProvider),
  );
});
