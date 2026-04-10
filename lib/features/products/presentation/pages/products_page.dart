import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mypime/core/routes/app_routes.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/product_categories/domain/entities/product_category_entity.dart';
import 'package:mypime/features/product_categories/presentation/providers/product_category_providers.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';
import 'package:mypime/features/products/domain/product_stock_utils.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';

class ProductsPage extends ConsumerWidget {
  const ProductsPage({super.key});

  String _categoryName(String categoryId, List<ProductCategoryEntity> cats) {
    for (final c in cats) {
      if (c.id == categoryId) return c.name;
    }
    return categoryId;
  }

  List<ProductEntity> _filterSearch(List<ProductEntity> items, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return items;
    return items.where((p) {
      if (p.name.toLowerCase().contains(q)) return true;
      final sku = p.sku;
      if (sku != null && sku.toLowerCase().contains(q)) return true;
      return false;
    }).toList();
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Eliminar "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      try {
        await ref.read(productsNotifierProvider.notifier).remove(product.id);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.toString())),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(productCategoryFilterProvider);
    final search = ref.watch(productManagementSearchProvider);
    final categoriesAsync = ref.watch(productCategoriesNotifierProvider);
    final productsAsync = ref.watch(productsNotifierProvider);
    final catalogAsync = ref.watch(fullProductCatalogProvider);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Productos',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    productsAsync.when(
                      loading: () => const SizedBox(height: 18),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                      data: (items) => Text(
                        '${items.length} productos en vista',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton.icon(
                onPressed: () => context.push(AppRoutes.productNew),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo producto'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          catalogAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (all) {
              final totalStock = all.fold<int>(
                0,
                (s, p) => s + (p.stock ?? 0),
              );
              final low = all.where(productIsLowStock).length;
              final out = all.where(productIsOutOfStock).length;
              return LayoutBuilder(
                builder: (context, c) {
                  final cols = c.maxWidth > 900
                      ? 4
                      : c.maxWidth > 600
                          ? 2
                          : 1;
                  return GridView.count(
                    crossAxisCount: cols,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: cols == 1 ? 3.2 : 1.8,
                    children: [
                      _MiniKpi(
                        title: 'Total productos',
                        value: '${all.length}',
                        color: Colors.blue.shade700,
                      ),
                      _MiniKpi(
                        title: 'Stock total',
                        value: '$totalStock',
                        color: AppColors.primaryTeal,
                      ),
                      _MiniKpi(
                        title: 'Stock bajo',
                        value: '$low',
                        color: Colors.orange.shade800,
                        emphasize: true,
                      ),
                      _MiniKpi(
                        title: 'Agotados',
                        value: '$out',
                        color: AppColors.danger,
                        emphasize: true,
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          TextField(
            onChanged: (v) =>
                ref.read(productManagementSearchProvider.notifier).state = v,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Buscar por nombre o SKU...',
            ),
          ),
          const SizedBox(height: 12),
          categoriesAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => Text('Categorías: $e'),
            data: (categories) {
              return DropdownButtonFormField<String?>(
                initialValue: filter,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('Todas las categorías'),
                  ),
                  ...categories.map(
                    (c) => DropdownMenuItem<String?>(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  ),
                ],
                onChanged: (v) {
                  ref.read(productCategoryFilterProvider.notifier).state = v;
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: productsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text(e.toString())),
              data: (items) {
                final cats = categoriesAsync.valueOrNull ?? [];
                final filtered = _filterSearch(items, search);
                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(productsNotifierProvider.notifier).refresh();
                    ref.invalidate(fullProductCatalogProvider);
                  },
                  child: filtered.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: const [
                            SizedBox(height: 80),
                            Center(child: Text('No hay productos')),
                          ],
                        )
                      : LayoutBuilder(
                          builder: (context, c) {
                            final cross = c.maxWidth > 1200
                                ? 4
                                : c.maxWidth > 800
                                    ? 3
                                    : c.maxWidth > 500
                                        ? 2
                                        : 1;
                            return GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cross,
                                mainAxisSpacing: 16,
                                crossAxisSpacing: 16,
                                childAspectRatio: 0.72,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final p = filtered[i];
                                return _ManagementProductCard(
                                  product: p,
                                  categoryName: _categoryName(p.categoryId, cats),
                                  low: productIsLowStock(p),
                                  out: productIsOutOfStock(p),
                                  onEdit: () => context.push(
                                    AppRoutes.productEdit(p.id),
                                  ),
                                  onDelete: () => _confirmDelete(context, ref, p),
                                  onToggle: (v) async {
                                    try {
                                      await ref
                                          .read(productsNotifierProvider.notifier)
                                          .setActive(p.id, v);
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      }
                                    }
                                  },
                                );
                              },
                            );
                          },
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniKpi extends StatelessWidget {
  const _MiniKpi({
    required this.title,
    required this.value,
    required this.color,
    this.emphasize = false,
  });

  final String title;
  final String value;
  final Color color;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: emphasize ? color : const Color(0xFF0f172a),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManagementProductCard extends StatelessWidget {
  const _ManagementProductCard({
    required this.product,
    required this.categoryName,
    required this.low,
    required this.out,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final ProductEntity product;
  final String categoryName;
  final bool low;
  final bool out;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final void Function(bool) onToggle;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  color: const Color(0xFFf8fafc),
                  child: Center(
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ),
                if (low || out)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.warningBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        out ? 'Agotado' : 'Pocas unidades',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.warningText,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.sku != null && product.sku!.isNotEmpty)
                  Text(
                    'SKU: ${product.sku}',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Chip(
                      label: Text(
                        categoryName,
                        style: const TextStyle(fontSize: 11),
                      ),
                      padding: EdgeInsets.zero,
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Text(
                      'Stock: ${product.stock ?? '—'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: low || out ? AppColors.danger : Colors.black54,
                        fontWeight: low || out ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryTeal,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: product.isActive,
                      onChanged: onToggle,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20),
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20),
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
