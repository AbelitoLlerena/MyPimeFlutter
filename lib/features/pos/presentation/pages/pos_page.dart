import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/product_categories/domain/entities/product_category_entity.dart';
import 'package:mypime/features/product_categories/presentation/providers/product_category_providers.dart';
import 'package:mypime/features/pos/presentation/providers/cart_provider.dart';
import 'package:mypime/features/pos/presentation/widgets/pos_checkout_dialog.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';
import 'package:mypime/features/products/domain/product_stock_utils.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';

class PosPage extends ConsumerStatefulWidget {
  const PosPage({super.key});

  @override
  ConsumerState<PosPage> createState() => _PosPageState();
}

class _PosPageState extends ConsumerState<PosPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductEntity> _filterProducts(
    List<ProductEntity> all,
    String? categoryId,
    String query,
  ) {
    var list = all.where((p) => p.isActive).toList();
    if (categoryId != null && categoryId.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryId).toList();
    }
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((p) {
      final name = p.name.toLowerCase();
      final sku = (p.sku ?? '').toLowerCase();
      return name.contains(q) || sku.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesNotifierProvider);
    final catalogAsync = ref.watch(fullProductCatalogProvider);
    final posFilter = ref.watch(posCategoryFilterProvider);
    final cart = ref.watch(cartProvider);
    final total = ref.watch(cartTotalProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryTeal.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.point_of_sale, color: AppColors.primaryTeal),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Punto de Venta',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Selecciona productos para agregar al carrito',
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final wide = c.maxWidth > 960;
                final mainArea = Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Buscar producto o SKU...',
                      ),
                    ),
                    const SizedBox(height: 12),
                    categoriesAsync.when(
                      loading: () => const SizedBox(height: 8),
                      error: (error, stackTrace) => const SizedBox.shrink(),
                      data: (cats) => _CategoryChips(
                        categories: cats,
                        selectedId: posFilter,
                        onSelected: (id) {
                          ref.read(posCategoryFilterProvider.notifier).state = id;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: catalogAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Center(child: Text(e.toString())),
                        data: (products) {
                          final filtered = _filterProducts(
                            products,
                            posFilter,
                            _searchController.text,
                          );
                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(fullProductCatalogProvider);
                            },
                            child: GridView.builder(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: wide ? 4 : 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.78,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final p = filtered[i];
                                final catName = _catName(p.categoryId, categoriesAsync.valueOrNull ?? []);
                                final low = productIsLowStock(p);
                                return _PosProductCard(
                                  product: p,
                                  categoryLabel: catName,
                                  lowStock: low,
                                  onTap: () => ref.read(cartProvider.notifier).add(p),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );

                final cartPanel = _CartPanel(
                  lines: cart,
                  total: total,
                  onCobrar: () async {
                    if (cart.isEmpty) return;
                    final ok = await showPosCheckoutDialog(
                      context: context,
                      ref: ref,
                      cart: cart,
                      total: total,
                    );
                    if (ok && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Venta registrada correctamente')),
                      );
                    }
                  },
                  onClear: () => ref.read(cartProvider.notifier).clear(),
                  onRemove: (id) => ref.read(cartProvider.notifier).removeLine(id),
                  onDec: (id) => ref.read(cartProvider.notifier).decrement(id),
                );

                if (wide) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: mainArea),
                      const SizedBox(width: 16),
                      SizedBox(width: 320, child: cartPanel),
                    ],
                  );
                }
                return Column(
                  children: [
                    Expanded(child: mainArea),
                    const SizedBox(height: 12),
                    SizedBox(height: 220, child: cartPanel),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _catName(String id, List<ProductCategoryEntity> cats) {
    for (final c in cats) {
      if (c.id == id) return c.name;
    }
    return '—';
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
  });

  final List<ProductCategoryEntity> categories;
  final String? selectedId;
  final void Function(String?) onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: const Text('Todas'),
              selected: selectedId == null || selectedId!.isEmpty,
              onSelected: (_) => onSelected(null),
              selectedColor: AppColors.primaryTeal.withValues(alpha: 0.35),
            ),
          ),
          ...categories.map(
            (c) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(c.name),
                selected: selectedId == c.id,
                onSelected: (_) => onSelected(c.id),
                selectedColor: AppColors.primaryTeal.withValues(alpha: 0.35),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PosProductCard extends StatelessWidget {
  const _PosProductCard({
    required this.product,
    required this.categoryLabel,
    required this.lowStock,
    required this.onTap,
  });

  final ProductEntity product;
  final String categoryLabel;
  final bool lowStock;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFf1f5f9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.inventory_2_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: AppColors.primaryTeal,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryTeal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        categoryLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF0f766e)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Stock: ${product.stock ?? '—'}',
                    style: TextStyle(
                      fontSize: 11,
                      color: lowStock ? AppColors.danger : Colors.black54,
                      fontWeight: lowStock ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CartPanel extends StatelessWidget {
  const _CartPanel({
    required this.lines,
    required this.total,
    required this.onCobrar,
    required this.onClear,
    required this.onRemove,
    required this.onDec,
  });

  final List<CartLine> lines;
  final double total;
  final VoidCallback onCobrar;
  final VoidCallback onClear;
  final void Function(String id) onRemove;
  final void Function(String id) onDec;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.shopping_cart_outlined, size: 22),
                const SizedBox(width: 8),
                Text(
                  'Carrito',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const Spacer(),
                if (lines.isNotEmpty)
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Vaciar'),
                  ),
              ],
            ),
            const Divider(),
            Expanded(
              child: lines.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 48, color: Colors.grey.shade300),
                          const SizedBox(height: 8),
                          Text(
                            'Carrito vacío',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Toca un producto para agregarlo',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: lines.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final line = lines[i];
                        return ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          title: Text(line.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text(
                            '${line.quantity} × \$${line.unitPrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, size: 20),
                                onPressed: () => onDec(line.productId),
                              ),
                              IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () => onRemove(line.productId),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(
                  '\$${total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: lines.isEmpty ? null : onCobrar,
              child: const Text('Cobrar'),
            ),
          ],
        ),
      ),
    );
  }
}
