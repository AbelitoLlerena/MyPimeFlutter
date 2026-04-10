import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mypime/features/product_categories/presentation/providers/product_category_providers.dart';

class ProductCategoryFormPage extends ConsumerStatefulWidget {
  const ProductCategoryFormPage({super.key, this.categoryId});

  final String? categoryId;

  bool get isEditing => categoryId != null;

  @override
  ConsumerState<ProductCategoryFormPage> createState() =>
      _ProductCategoryFormPageState();
}

class _ProductCategoryFormPageState extends ConsumerState<ProductCategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _seededFromRemote = false;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final name = _nameController.text.trim();
    final desc = _descriptionController.text.trim();

    setState(() => _saving = true);
    try {
      final notifier = ref.read(productCategoriesNotifierProvider.notifier);
      if (widget.isEditing) {
        await notifier.saveChanges(
          widget.categoryId!,
          name: name,
          description: desc.isEmpty ? null : desc,
        );
      } else {
        await notifier.create(
          name: name,
          description: desc.isEmpty ? null : desc,
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

  Widget _formScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Editar categoría' : 'Nueva categoría'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _submit,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditing) {
      return _formScaffold();
    }

    final async = ref.watch(productCategoryByIdProvider(widget.categoryId!));

    return async.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(e.toString())),
      ),
      data: (category) {
        if (!_seededFromRemote) {
          _seededFromRemote = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _nameController.text = category.name;
            _descriptionController.text = category.description ?? '';
          });
        }
        return _formScaffold();
      },
    );
  }
}
