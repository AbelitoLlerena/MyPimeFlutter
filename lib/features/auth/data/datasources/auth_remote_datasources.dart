import 'package:mypime/core/network/api_client.dart';
import 'package:mypime/features/auth/data/models/auth_model.dart';

class AuthRemoteDataSource {
  final ApiClient api;

  AuthRemoteDataSource(this.api);

  // Future<AuthModel> login(String name, String password) {
  //   return api.post<AuthModel>(
  //     '/auth/login',
  //     data: {
  //       'name': name,
  //       'password': password,
  //     },
  //     parser: (data) => AuthModel.fromJson(data),
  //   );
  // }

  Future<AuthModel> login(String name, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // simula red

    return AuthModel(
      accessToken: "fake_token_123",
      user: {
        "id": "1",
        "name": name,
        "role": name == "admin" ? "ADMIN" : "SELLER",
      },
    );
  }

  // Future<AuthModel> signUp(
  //   String name,
  //   String password,
  //   String role,
  // ) {
  //   return api.post<AuthModel>(
  //     '/auth/signup',
  //     data: {
  //       'name': name,
  //       'password': password,
  //       'role': role,
  //     },
  //     parser: (data) => AuthModel.fromJson(data),
  //   );
  // }

  Future<AuthModel> signUp(String name, String password, String role) async {
    await Future.delayed(const Duration(seconds: 1));

    return AuthModel(
      accessToken: "fake_token_signup",
      // role: role,
      user: {
        "id": "2",
        "name": name,
        "role": role,
      },
    );
  }
}