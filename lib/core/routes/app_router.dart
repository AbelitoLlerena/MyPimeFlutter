// app_router
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/routes/router_notifier.dart';
import 'package:mypime/domain/enums/user_role_enum.dart';
import '../../presentation/features/auth/widgets/login_page.dart';
import '../../presentation/features/home_page.dart';
import '../di/injector.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: GoRouterNotifier(ref),

      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);
        final loggedIn = authState.value != null;
        final role = authState.value?.user.role;  

        final location = state.uri.path;

        if (!loggedIn && location != AppRoutes.login) {
          return AppRoutes.login;
        }

        if (loggedIn && location == AppRoutes.login) {
          return AppRoutes.home;
        }

        if (role != UserRole.admin && [

        ].contains(location)) {
          return AppRoutes.home;
        }

        return null;
      },

      routes: [
        GoRoute(
          path: AppRoutes.login,
          builder: (_, _) => const LoginPage(),
        ),
        GoRoute(
          path: AppRoutes.home,
          builder: (_, _) => const HomePage(),
        ),
        // GoRoute(
        //   path: '/user/:id',
        //   builder: (context, state) {
        //     final id = state.pathParameters['id'];
        //     return UserPage(id: id!);
        //   },
        // );
      ],
    );
  }
}