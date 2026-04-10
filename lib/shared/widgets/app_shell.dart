import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mypime/core/routes/app_routes.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/auth/presentation/providers/auth_provider.dart';

class SidebarNavItem {
  const SidebarNavItem({
    required this.path,
    required this.label,
    required this.icon,
  });

  final String path;
  final String label;
  final IconData icon;
}

final List<SidebarNavItem> kShellRoutes = [
  SidebarNavItem(path: AppRoutes.dashboard, label: 'Dashboard', icon: Icons.dashboard_outlined),
  SidebarNavItem(path: AppRoutes.pos, label: 'Punto de Venta', icon: Icons.point_of_sale_outlined),
  SidebarNavItem(path: AppRoutes.products, label: 'Productos', icon: Icons.inventory_2_outlined),
  SidebarNavItem(path: AppRoutes.categories, label: 'Categorías', icon: Icons.category_outlined),
  SidebarNavItem(path: AppRoutes.inventory, label: 'Inventario', icon: Icons.fact_check_outlined),
  SidebarNavItem(path: AppRoutes.sales, label: 'Ventas', icon: Icons.receipt_long_outlined),
];

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final width = MediaQuery.sizeOf(context).width;
    final useDrawer = width < 900;

    final sidebar = _SidebarContent(
      location: location,
      onSelect: (path) => context.go(path),
      onLogout: () => ref.read(authStateNotifierProvider.notifier).logout(),
    );

    if (useDrawer) {
      return Scaffold(
        backgroundColor: AppColors.pageBackground,
        appBar: AppBar(
          title: const Text('VentaPOS'),
          backgroundColor: AppColors.sidebar,
          foregroundColor: Colors.white,
        ),
        drawer: Drawer(
          width: 280,
          backgroundColor: AppColors.sidebar,
          child: sidebar,
        ),
        body: child,
      );
    }

    return Scaffold(
      backgroundColor: AppColors.pageBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 256,
            child: Material(
              color: AppColors.sidebar,
              child: sidebar,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _SidebarContent extends StatelessWidget {
  const _SidebarContent({
    required this.location,
    required this.onSelect,
    required this.onLogout,
  });

  final String location;
  final void Function(String path) onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.storefront, color: AppColors.primaryGreen, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VentaPOS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Sistema de Ventas',
                        style: TextStyle(color: AppColors.sidebarText, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          for (final r in kShellRoutes)
            _NavTile(
              label: r.label,
              icon: r.icon,
              selected: _selectedStatic(r.path, location),
              onTap: () {
                onSelect(r.path);
                if (Scaffold.maybeOf(context)?.isDrawerOpen ?? false) {
                  Navigator.pop(context);
                }
              },
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextButton.icon(
              onPressed: onLogout,
              icon: const Icon(Icons.logout, color: AppColors.sidebarText, size: 20),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(color: AppColors.sidebarText),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Center(
              child: Text(
                'VentaPOS v1.0',
                style: TextStyle(color: AppColors.sidebarText, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _selectedStatic(String routePath, String location) {
    if (routePath == AppRoutes.dashboard) {
      return location == AppRoutes.dashboard || location == AppRoutes.home;
    }
    return location == routePath || location.startsWith('$routePath/');
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: selected ? AppColors.primaryTeal.withValues(alpha: 0.25) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? Colors.white : AppColors.sidebarText,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : AppColors.sidebarText,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (selected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
