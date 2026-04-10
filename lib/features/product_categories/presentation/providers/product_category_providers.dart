import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/product_categories/data/repositories/product_category_repository_impl.dart';
import 'package:mypime/features/product_categories/domain/entities/product_category_entity.dart';
import 'package:mypime/features/product_categories/domain/repositories/product_category_repository.dart';
import 'package:mypime/features/product_categories/domain/usecases/create_product_category.dart';
import 'package:mypime/features/product_categories/domain/usecases/delete_product_category.dart';
import 'package:mypime/features/product_categories/domain/usecases/get_product_categories.dart';
import 'package:mypime/features/product_categories/domain/usecases/get_product_category.dart';
import 'package:mypime/features/product_categories/domain/usecases/update_product_category.dart';
import 'package:mypime/shared/providers/sync_providers.dart';

final productCategoryRepositoryProvider =
    Provider<ProductCategoryRepository>((ref) {
  return ProductCategoryRepositoryImpl(ref.watch(isarProvider));
});

final getProductCategoriesUseCaseProvider = Provider<GetProductCategories>((ref) {
  return GetProductCategories(ref.watch(productCategoryRepositoryProvider));
});

final getProductCategoryUseCaseProvider = Provider<GetProductCategory>((ref) {
  return GetProductCategory(ref.watch(productCategoryRepositoryProvider));
});

final createProductCategoryUseCaseProvider = Provider<CreateProductCategory>((ref) {
  return CreateProductCategory(ref.watch(productCategoryRepositoryProvider));
});

final updateProductCategoryUseCaseProvider = Provider<UpdateProductCategory>((ref) {
  return UpdateProductCategory(ref.watch(productCategoryRepositoryProvider));
});

final deleteProductCategoryUseCaseProvider = Provider<DeleteProductCategory>((ref) {
  return DeleteProductCategory(ref.watch(productCategoryRepositoryProvider));
});

final productCategoryByIdProvider =
    FutureProvider.family<ProductCategoryEntity, String>((ref, id) async {
  final useCase = ref.watch(getProductCategoryUseCaseProvider);
  return useCase(id);
});

final productCategoriesNotifierProvider =
    AsyncNotifierProvider<ProductCategoriesNotifier, List<ProductCategoryEntity>>(
  ProductCategoriesNotifier.new,
);

class ProductCategoriesNotifier
    extends AsyncNotifier<List<ProductCategoryEntity>> {
  Future<List<ProductCategoryEntity>> _load() async {
    final useCase = ref.read(getProductCategoriesUseCaseProvider);
    return useCase();
  }

  @override
  Future<List<ProductCategoryEntity>> build() => _load();

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(_load);
  }

  Future<void> remove(String id) async {
    final del = ref.read(deleteProductCategoryUseCaseProvider);
    await del(id);
    state = await AsyncValue.guard(_load);
  }

  Future<void> create({
    required String name,
    String? description,
  }) async {
    final uc = ref.read(createProductCategoryUseCaseProvider);
    await uc(name: name, description: description);
    state = await AsyncValue.guard(_load);
  }

  Future<void> saveChanges(
    String id, {
    required String name,
    String? description,
  }) async {
    final uc = ref.read(updateProductCategoryUseCaseProvider);
    await uc(id, name: name, description: description);
    state = await AsyncValue.guard(_load);
  }
}
