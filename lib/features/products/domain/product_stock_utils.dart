import 'package:mypime/features/products/domain/entities/product_entity.dart';

/// Stock bajo: respeta `minStock` del backend; si no viene, umbral por defecto.
bool productIsLowStock(ProductEntity p, {int defaultThreshold = 5}) {
  final s = p.stock;
  if (s == null) return false;
  final m = p.minStock;
  if (m != null) return s <= m;
  return s <= defaultThreshold;
}

bool productIsOutOfStock(ProductEntity p) {
  final s = p.stock;
  return s != null && s <= 0;
}
