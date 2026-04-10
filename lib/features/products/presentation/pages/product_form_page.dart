import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mypime/features/product_categories/domain/entities/product_category_entity.dart';
import 'package:mypime/features/product_categories/presentation/providers/product_category_providers.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';

class ProductFormPage extends ConsumerStatefulWidget {
  const ProductFormPage({super.key, this.productId});

  final String? productId;

  bool get isEditing => productId != null;

  @override
  ConsumerState<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends ConsumerState<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _skuController = TextEditingController();
  final _minStockController = TextEditingController();
  String? _selectedCategoryId;
  bool _isActive = true;
  bool _seededFromRemote = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _skuController.dispose();
    _minStockController.dispose();
    super.dispose();
  }

  Future<void> _submit(List<ProductCategoryEntity> categories) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final categoryId = _selectedCategoryId;
    if (categoryId == null ||
        categoryId.isEmpty ||
        !categories.any((c) => c.id == categoryId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona una categoría')),
      );
      return;
    }

    final price = double.tryParse(
      _priceController.text.replaceAll(',', '.'),
    );
    if (price == null || price < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precio no válido')),
      );
      return;
    }

    int? stock;
    final stockText = _stockController.text.trim();
    if (stockText.isNotEmpty) {
      stock = int.tryParse(stockText);
      if (stock == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock no válido')),
        );
        return;
      }
    }

    int? minStock;
    final minStockText = _minStockController.text.trim();
    if (minStockText.isNotEmpty) {
      minStock = int.tryParse(minStockText);
      if (minStock == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock mínimo no válido')),
        );
        return;
      }
    }

    final sku = _skuController.text.trim();

    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    setState(() => _saving = true);
    try {
      final notifier = ref.read(productsNotifierProvider.notifier);
      if (widget.isEditing) {
        await notifier.saveChanges(
          widget.productId!,
          name: name,
          description: desc.isEmpty ? null : desc,
          sku: sku.isEmpty ? null : sku,
          price: price,
          categoryId: categoryId,
          stock: stock,
          minStock: minStock,
          isActive: _isActive,
        );
      } else {
        await notifier.create(
          name: name,
          description: desc.isEmpty ? null : desc,
          sku: sku.isEmpty ? null : sku,
          price: price,
          categoryId: categoryId,
          stock: stock,
          minStock: minStock,
          isActive: _isActive,
        );
      }
      if (mounted) context.pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildFormBody(List<ProductCategoryEntity> categories) {
    final hasCategories = categories.isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!hasCategories)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: MaterialBanner(
                  content: const Text(
                    'Crea al menos una categoría antes de guardar productos.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              ),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Precio',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _skuController,
              decoration: const InputDecoration(
                labelText: 'SKU / código (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stockController,
              decoration: const InputDecoration(
                labelText: 'Stock (opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _minStockController,
              decoration: const InputDecoration(
                labelText: 'Stock mínimo / alerta (opcional)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Producto activo'),
              subtitle: const Text('Si está desactivado no aparece en el POS'),
              value: _isActive,
              onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCategoryId != null &&
                      categories.any((c) => c.id == _selectedCategoryId)
                  ? _selectedCategoryId
                  : null,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(
                      value: c.id,
                      child: Text(c.name),
                    ),
                  )
                  .toList(),
              onChanged: hasCategories
                  ? (v) => setState(() => _selectedCategoryId = v)
                  : null,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: (_saving || !hasCategories) ? null : () => _submit(categories),
              child: _saving
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(productCategoriesNotifierProvider);

    return categoriesAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(e.toString())),
      ),
      data: (categories) {
        if (!widget.isEditing) {
          return Scaffold(
            appBar: AppBar(title: const Text('Nuevo producto')),
            body: _buildFormBody(categories),
          );
        }

        final asyncProduct = ref.watch(productByIdProvider(widget.productId!));

        return asyncProduct.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text(e.toString())),
          ),
          data: (product) {
            if (!_seededFromRemote) {
              _seededFromRemote = true;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;
                _nameController.text = product.name;
                _descriptionController.text = product.description ?? '';
                _priceController.text = product.price.toString();
                _stockController.text = product.stock?.toString() ?? '';
                _skuController.text = product.sku ?? '';
                _minStockController.text = product.minStock?.toString() ?? '';
                _isActive = product.isActive;
                _selectedCategoryId = product.categoryId;
              });
            }
            return Scaffold(
              appBar: AppBar(title: const Text('Editar producto')),
              body: _buildFormBody(categories),
            );
          },
        );
      },
    );
  }
}
