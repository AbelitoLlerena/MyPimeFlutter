import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mypime/core/routes/app_routes.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';
import 'package:mypime/features/products/domain/product_stock_utils.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';
import 'package:mypime/features/sales/domain/entities/sale_entity.dart';
import 'package:mypime/features/sales/presentation/providers/sales_providers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(fullProductCatalogProvider);
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy').format(now);
    final todayKey = DateTime(now.year, now.month, now.day);
    final salesAsync = ref.watch(salesByDayProvider(todayKey));

    return catalog.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (products) {
        final active = products.where((p) => p.isActive).length;
        final low = products.where(productIsLowStock).length;

        return salesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ventas: $e')),
          data: (salesToday) {
            final salesTotal = salesToday.fold<double>(0, (a, s) => a + s.total);
            final tickets = salesToday.length;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buenos días',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final cols = w > 1100
                          ? 4
                          : w > 700
                              ? 2
                              : 1;
                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: cols == 1 ? 2.4 : 1.6,
                        children: [
                          _KpiCard(
                            title: 'Ventas hoy',
                            value: '\$${salesTotal.toStringAsFixed(2)}',
                            subtitle: '$tickets transacciones',
                            icon: Icons.attach_money,
                            iconColor: AppColors.primaryGreen,
                          ),
                          _KpiCard(
                            title: 'Tickets hoy',
                            value: '$tickets',
                            subtitle: 'ventas completadas',
                            icon: Icons.shopping_bag_outlined,
                            iconColor: Colors.blue,
                          ),
                          _KpiCard(
                            title: 'Productos',
                            value: '$active',
                            subtitle: 'productos activos',
                            icon: Icons.inventory_2_outlined,
                            iconColor: Colors.orange,
                          ),
                          _KpiCard(
                            title: 'Stock bajo',
                            value: '$low',
                            subtitle: 'necesitan reabastecimiento',
                            icon: Icons.warning_amber_rounded,
                            iconColor: AppColors.danger,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, c) {
                      if (c.maxWidth > 900) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _RecentSalesCard(
                                sales: salesToday,
                                onPos: () => context.go(AppRoutes.pos),
                                onViewAll: () => context.go(AppRoutes.sales),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(flex: 2, child: _LowStockCard(products: products)),
                          ],
                        );
                      }
                      return Column(
                        children: [
                          _RecentSalesCard(
                            sales: salesToday,
                            onPos: () => context.go(AppRoutes.pos),
                            onViewAll: () => context.go(AppRoutes.sales),
                          ),
                          const SizedBox(height: 16),
                          _LowStockCard(products: products),
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecentSalesCard extends StatelessWidget {
  const _RecentSalesCard({
    required this.sales,
    required this.onPos,
    required this.onViewAll,
  });

  final List<SaleEntity> sales;
  final VoidCallback onPos;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final recent = sales.take(3).toList();
    final timeFmt = DateFormat('HH:mm');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ventas recientes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todas →'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      Text(
                        'Aún no hay ventas registradas',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: onPos,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Ir al Punto de Venta'),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recent.map((s) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.receipt_long, color: AppColors.primaryTeal),
                  title: Text(
                    '\$${s.total.toStringAsFixed(2)} · ${s.lines.length} productos',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '${timeFmt.format(s.createdAt)} · ${_paymentLabel(s.paymentMethod)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  String _paymentLabel(String? m) {
    switch (m) {
      case 'card':
        return 'Tarjeta';
      case 'cash':
        return 'Efectivo';
      default:
        return m ?? '—';
    }
  }
}

class _LowStockCard extends StatelessWidget {
  const _LowStockCard({required this.products});

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    final lowList = products.where(productIsLowStock).take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stock bajo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: () => context.go(AppRoutes.products),
                  child: const Text('Productos →'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (lowList.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  'Sin alertas de stock',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              )
            else
              ...lowList.map((p) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Min: ${p.minStock ?? "—"}'),
                  trailing: Text(
                    '${p.stock ?? 0}',
                    style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
