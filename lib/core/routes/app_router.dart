// app_router
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/auth/presentation/pages/login_page.dart';
import 'package:mypime/features/home_page.dart';
import 'package:mypime/shared/providers/router_notifier.dart';
import 'app_routes.dart';

class AppRouter {
  static GoRouter createRouter(WidgetRef ref) {
    final notifier = ref.watch(goRouterNotifierProvider);
    
    return GoRouter(
      initialLocation: AppRoutes.login,
      refreshListenable: notifier,

      redirect: (context, state) {
        final loggedIn = notifier.isLoggedIn;
        final isAdmin = notifier.isAdmin;  

        final location = state.uri.path;

        if (!loggedIn && location != AppRoutes.login) {
          return AppRoutes.login;
        }

        if (loggedIn && location == AppRoutes.login) {
          return AppRoutes.home;
        }

        if (isAdmin && [

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