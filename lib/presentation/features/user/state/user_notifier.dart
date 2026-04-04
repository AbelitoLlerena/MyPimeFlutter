import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/usecases/get_users.dart';
import '../../../../domain/usecases/delete_user.dart';

class UsersNotifier {
  final GetUsers getUsers;
  final DeleteUser deleteUser;

  List<UserEntity> users = [];
  bool loading = false;

  UsersNotifier({
    required this.getUsers,
    required this.deleteUser,
  });

  Future<void> loadUsers() async {
    loading = true;
    users = await getUsers();
    loading = false;
  }

  Future<void> removeUser(String id) async {
    await deleteUser(id);
    users.removeWhere((u) => u.id == id);
  }
}