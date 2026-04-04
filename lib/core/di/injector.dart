import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mypime/domain/entities/auth_entity.dart';

import '../auth/token_storage.dart';
import '../network/dio_client.dart';
import '../network/api_client.dart';

// AUTH
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import '../../presentation/features/auth/state/auth_notifier.dart';

// USERS
// import '../../data/datasources/remote/user_remote_datasource.dart';
// import '../../data/repositories/user_repository_impl.dart';
// import '../../domain/repositories/user_repository.dart';
// import '../../domain/usecases/get_users.dart';
// import '../../domain/usecases/delete_user.dart';
// import '../../presentation/features/user/state/user_notifier.dart';

/// -------------------------
/// CORE
/// -------------------------

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(tokenStorageProvider);

  final dioClient = DioClient.create(
    baseUrl: 'http://localhost:3000',
    storage: storage,
  );

  return dioClient.dio;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(ref.watch(dioProvider));
});

/// -------------------------
/// AUTH
/// -------------------------

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

/// Notifier (equivalent to your AuthNotifier in GetIt)
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthEntity?>>((ref) {
  return AuthNotifier(
    loginUseCase: ref.watch(loginUseCaseProvider),
    signUpUseCase: ref.watch(signUpUseCaseProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  );
});
