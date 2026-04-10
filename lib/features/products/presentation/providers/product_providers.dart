import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/products/data/repositories/product_repository_impl.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';
import 'package:mypime/features/products/domain/repositories/product_repository.dart';
import 'package:mypime/features/products/domain/usecases/create_product.dart';
import 'package:mypime/features/products/domain/usecases/delete_product.dart';
import 'package:mypime/features/products/domain/usecases/get_product.dart';
import 'package:mypime/features/products/domain/usecases/get_products.dart';
import 'package:mypime/features/products/domain/usecases/update_product.dart';
import 'package:mypime/shared/providers/sync_providers.dart';

/// Filtro de listado de productos por categoría (`null` = todas).
final productCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Filtro del Punto de Venta (independiente de la pantalla Productos).
final posCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Búsqueda en la pantalla de gestión de productos (nombre / SKU).
final productManagementSearchProvider = StateProvider<String>((ref) => '');

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(ref.watch(isarProvider));
});

final getProductsUseCaseProvider = Provider<GetProducts>((ref) {
  return GetProducts(ref.watch(productRepositoryProvider));
});

/// Catálogo completo para dashboard, POS e inventario (sin filtro de categoría).
final fullProductCatalogProvider =
    FutureProvider<List<ProductEntity>>((ref) async {
  final uc = ref.watch(getProductsUseCaseProvider);
  return uc(categoryId: null);
});

final getProductUseCaseProvider = Provider<GetProduct>((ref) {
  return GetProduct(ref.watch(productRepositoryProvider));
});

final createProductUseCaseProvider = Provider<CreateProduct>((ref) {
  return CreateProduct(ref.watch(productRepositoryProvider));
});

final updateProductUseCaseProvider = Provider<UpdateProduct>((ref) {
  return UpdateProduct(ref.watch(productRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider<DeleteProduct>((ref) {
  return DeleteProduct(ref.watch(productRepositoryProvider));
});

final productByIdProvider =
    FutureProvider.family<ProductEntity, String>((ref, id) async {
  final useCase = ref.watch(getProductUseCaseProvider);
  return useCase(id);
});

final productsNotifierProvider =
    AsyncNotifierProvider<ProductsNotifier, List<ProductEntity>>(
  ProductsNotifier.new,
);

class ProductsNotifier extends AsyncNotifier<List<ProductEntity>> {
  Future<List<ProductEntity>> _fetch() async {
    final categoryId = ref.read(productCategoryFilterProvider);
    final useCase = ref.read(getProductsUseCaseProvider);
    return useCase(categoryId: categoryId);
  }

  @override
  Future<List<ProductEntity>> build() async {
    final categoryId = ref.watch(productCategoryFilterProvider);
    final useCase = ref.read(getProductsUseCaseProvider);
    return useCase(categoryId: categoryId);
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_fetch);
    ref.invalidate(fullProductCatalogProvider);
  }

  Future<void> remove(String id) async {
    final del = ref.read(deleteProductUseCaseProvider);
    await del(id);
    state = await AsyncValue.guard(_fetch);
    ref.invalidate(fullProductCatalogProvider);
  }

  Future<void> create({
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool isActive = true,
  }) async {
    final uc = ref.read(createProductUseCaseProvider);
    await uc(
      name: name,
      description: description,
      sku: sku,
      price: price,
      categoryId: categoryId,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
    state = await AsyncValue.guard(_fetch);
    ref.invalidate(fullProductCatalogProvider);
  }

  Future<void> saveChanges(
    String id, {
    required String name,
    String? description,
    String? sku,
    required double price,
    required String categoryId,
    int? stock,
    int? minStock,
    bool? isActive,
  }) async {
    final uc = ref.read(updateProductUseCaseProvider);
    await uc(
      id,
      name: name,
      description: description,
      sku: sku,
      price: price,
      categoryId: categoryId,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
    state = await AsyncValue.guard(_fetch);
    ref.invalidate(fullProductCatalogProvider);
  }

  Future<void> setActive(String id, bool isActive) async {
    final get = ref.read(getProductUseCaseProvider);
    final current = await get(id);
    final uc = ref.read(updateProductUseCaseProvider);
    await uc(
      id,
      name: current.name,
      description: current.description,
      sku: current.sku,
      price: current.price,
      categoryId: current.categoryId,
      stock: current.stock,
      minStock: current.minStock,
      isActive: isActive,
    );
    state = await AsyncValue.guard(_fetch);
    ref.invalidate(fullProductCatalogProvider);
  }
}
