import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/products/presentation/providers/product_providers.dart';
import 'package:mypime/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:mypime/features/sales/domain/entities/sale_entity.dart';
import 'package:mypime/features/sales/domain/repositories/sales_repository.dart';
import 'package:mypime/features/sales/domain/usecases/create_sale.dart';
import 'package:mypime/features/sales/domain/usecases/get_sales_by_day.dart';
import 'package:mypime/shared/providers/sync_providers.dart';

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  return SalesRepositoryImpl(
    ref.watch(isarProvider),
    ref.watch(productRepositoryProvider),
  );
});

final createSaleUseCaseProvider = Provider<CreateSale>((ref) {
  return CreateSale(ref.watch(salesRepositoryProvider));
});

final getSalesByDayUseCaseProvider = Provider<GetSalesByDay>((ref) {
  return GetSalesByDay(ref.watch(salesRepositoryProvider));
});

/// Ventas de un día concreto (medianoche local).
final salesByDayProvider =
    FutureProvider.family<List<SaleEntity>, DateTime>((ref, day) async {
  final normalized = DateTime(day.year, day.month, day.day);
  final useCase = ref.watch(getSalesByDayUseCaseProvider);
  return useCase(normalized);
});
