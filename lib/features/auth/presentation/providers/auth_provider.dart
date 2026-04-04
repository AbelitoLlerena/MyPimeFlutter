import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/data/datasources/auth_remote_datasources.dart';
import 'package:mypime/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:mypime/features/auth/domain/repositories/auth_repository.dart';
import 'package:mypime/features/auth/domain/usecases/login_usecase.dart';
import 'package:mypime/features/auth/domain/usecases/signup_usecase.dart';
import 'package:mypime/shared/providers/api_client.dart';
import 'package:mypime/shared/providers/token_storage.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(apiClientProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(authRemoteDataSourceProvider),
    ref.watch(tokenStorageProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final signUpUseCaseProvider = Provider<SignUpUseCase>((ref) {
  return SignUpUseCase(ref.watch(authRepositoryProvider));
});
