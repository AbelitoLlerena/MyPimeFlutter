import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/core/theme/app_theme.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';
import 'package:mypime/features/products/domain/product_stock_utils.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';

class InventoryPage extends ConsumerStatefulWidget {
  const InventoryPage({super.key});

  @override
  ConsumerState<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends ConsumerState<InventoryPage> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncControllers(List<ProductEntity> products) {
    final ids = products.map((p) => p.id).toSet();
    for (final id in _controllers.keys.toList()) {
      if (!ids.contains(id)) {
        _controllers.remove(id)?.dispose();
      }
    }
    for (final p in products) {
      _controllers.putIfAbsent(p.id, TextEditingController.new);
    }
  }

  int? _parsedCount(String? text) {
    if (text == null || text.trim().isEmpty) return null;
    return int.tryParse(text.trim());
  }

  Future<void> _save(List<ProductEntity> products) async {
    final notifier = ref.read(productsNotifierProvider.notifier);
    var changed = 0;
    for (final p in products) {
      final physical = _parsedCount(_controllers[p.id]?.text);
      if (physical == null) continue;
      if (physical == p.stock) continue;
      try {
        await notifier.saveChanges(
          p.id,
          name: p.name,
          description: p.description,
          sku: p.sku,
          price: p.price,
          categoryId: p.categoryId,
          stock: physical,
          minStock: p.minStock,
          isActive: p.isActive,
        );
        changed++;
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${p.name}: $e')),
          );
        }
        return;
      }
    }
    if (mounted) {
      for (final c in _controllers.values) {
        c.clear();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(changed == 0 ? 'Sin cambios' : 'Guardado: $changed productos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(fullProductCatalogProvider);
    final now = DateTime.now();

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text(e.toString())),
      data: (products) {
        _syncControllers(products);
        final active = products.where((p) => p.isActive).length;
        final pending = products.where((p) {
          final v = _parsedCount(_controllers[p.id]?.text);
          return v != null && v != p.stock;
        }).length;

        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Conteo de Inventario',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} · $active productos activos',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _save(products),
                    icon: const Icon(Icons.save_outlined),
                    label: Text('Guardar conteo ($pending)'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Card(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: MediaQuery.sizeOf(context).width - 80,
                      ),
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          AppColors.pageBackground,
                        ),
                        columns: const [
                          DataColumn(label: Text('PRODUCTO')),
                          DataColumn(label: Text('SISTEMA'), numeric: true),
                          DataColumn(label: Text('CONTEO')),
                          DataColumn(label: Text('DIFERENCIA'), numeric: true),
                        ],
                        rows: [
                          for (final p in products)
                            DataRow(
                              cells: [
                                DataCell(
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name,
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                      ),
                                      if (p.sku != null && p.sku!.isNotEmpty)
                                        Text(
                                          p.sku!,
                                          style: TextStyle(
                                            color: Colors.grey.shade600,
                                            fontSize: 12,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    '${p.stock ?? 0}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: productIsLowStock(p)
                                          ? AppColors.danger
                                          : null,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  SizedBox(
                                    width: 100,
                                    child: TextField(
                                      controller: _controllers[p.id],
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      decoration: const InputDecoration(
                                        hintText: '—',
                                        isDense: true,
                                      ),
                                      onChanged: (_) => setState(() {}),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Builder(
                                    builder: (context) {
                                      final c = _parsedCount(_controllers[p.id]?.text);
                                      if (c == null) {
                                        return const Text('—');
                                      }
                                      final sys = p.stock ?? 0;
                                      final diff = c - sys;
                                      final color = diff == 0
                                          ? Colors.grey
                                          : diff > 0
                                              ? AppColors.primaryGreen
                                              : AppColors.danger;
                                      return Text(
                                        diff > 0 ? '+$diff' : '$diff',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: color,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
