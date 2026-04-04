import '../../models/user_model.dart';
import '../../../core/network/api_client.dart';

class UserRemoteDataSource {
  final ApiClient api;

  UserRemoteDataSource(this.api);

  Future<List<UserModel>> getUsers() {
    return api.get<List<UserModel>>(
      '/users',
      parser: (data) =>
          (data as List).map((e) => UserModel.fromJson(e)).toList(),
    );
  }

  Future<UserModel> getUser(String id) {
    return api.get<UserModel>(
      '/users/$id',
      parser: (data) => UserModel.fromJson(data),
    );
  }

  Future<void> deleteUser(String id) {
    return api.delete<void>(
      '/users/$id',
      parser: (_) {},
    );
  }
}