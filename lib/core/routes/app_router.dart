// app_router
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mypime/features/auth/presentation/pages/login_page.dart';
import 'package:mypime/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:mypime/features/inventory/presentation/pages/inventory_page.dart';
import 'package:mypime/features/pos/presentation/pages/pos_page.dart';
import 'package:mypime/features/product_categories/presentation/pages/product_categories_page.dart';
import 'package:mypime/features/product_categories/presentation/pages/product_category_form_page.dart';
import 'package:mypime/features/products/presentation/pages/product_form_page.dart';
import 'package:mypime/features/products/presentation/pages/products_page.dart';
import 'package:mypime/features/sales/presentation/pages/sales_history_page.dart';
import 'package:mypime/shared/providers/router_notifier.dart';
import 'package:mypime/shared/widgets/app_shell.dart';
import 'app_routes.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(goRouterNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    redirect: (context, state) {
      final loggedIn = notifier.isLoggedIn;
      final location = state.uri.path;

      if (!loggedIn && location != AppRoutes.login) {
        return AppRoutes.login;
      }

      if (loggedIn && location == AppRoutes.login) {
        return AppRoutes.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.login,
        builder: (_, _) => const LoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (_, _) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.home,
            redirect: (context, state) => AppRoutes.dashboard,
          ),
          GoRoute(
            path: AppRoutes.pos,
            builder: (_, _) => const PosPage(),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (_, _) => const ProductsPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const ProductFormPage(),
              ),
              GoRoute(
                path: ':productId/edit',
                builder: (context, state) {
                  final id = state.pathParameters['productId']!;
                  return ProductFormPage(productId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (_, _) => const ProductCategoriesPage(),
            routes: [
              GoRoute(
                path: 'new',
                builder: (_, _) => const ProductCategoryFormPage(),
              ),
              GoRoute(
                path: ':categoryId/edit',
                builder: (context, state) {
                  final id = state.pathParameters['categoryId']!;
                  return ProductCategoryFormPage(categoryId: id);
                },
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.inventory,
            builder: (_, _) => const InventoryPage(),
          ),
          GoRoute(
            path: AppRoutes.sales,
            builder: (_, _) => const SalesHistoryPage(),
          ),
        ],
      ),
    ],
  );
});
