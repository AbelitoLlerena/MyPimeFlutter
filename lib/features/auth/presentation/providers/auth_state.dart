import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mypime/features/auth/domain/entities/auth_entity.dart';
import 'package:mypime/features/auth/presentation/providers/auth_notifier.dart';
import 'package:mypime/features/auth/presentation/providers/auth_provider.dart';
import 'package:mypime/shared/providers/token_storage.dart';

final authStateNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthEntity?>>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
