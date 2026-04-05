import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/presentation/providers/auth_provider.dart';
import 'package:mypime/features/users/domain/entities/user_entity.dart';
import 'package:mypime/features/users/domain/enums/user_role_enum.dart';

class GoRouterNotifier extends ChangeNotifier {
  GoRouterNotifier(this.ref) {
    ref.listen<AsyncValue<UserEntity?>>(
      authStateNotifierProvider,
      (_, _) => notifyListeners(),
    );
  }

  final Ref ref;

  AsyncValue<UserEntity?> get authState =>
    ref.read(authStateNotifierProvider);

  bool get isLoggedIn => authState.value != null;
  bool get isAdmin => authState.value?.role == UserRole.admin;
}

final goRouterNotifierProvider = ChangeNotifierProvider<GoRouterNotifier>((ref) {
  return GoRouterNotifier(ref);
});
