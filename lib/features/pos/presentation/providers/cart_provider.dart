import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mypime/features/products/domain/entities/product_entity.dart';

class CartLine {
  CartLine({
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
  });

  final String productId;
  final String name;
  final double unitPrice;
  int quantity;

  double get lineTotal => unitPrice * quantity;
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(CartNotifier.new);

final cartTotalProvider = Provider<double>((ref) {
  final lines = ref.watch(cartProvider);
  return lines.fold<double>(0, (sum, line) => sum + line.lineTotal);
});

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() => [];

  void add(ProductEntity product) {
    if (!product.isActive) return;
    final stock = product.stock;
    final existing = state.indexWhere((l) => l.productId == product.id);
    if (existing >= 0) {
      final line = state[existing];
      final nextQty = line.quantity + 1;
      if (stock != null && nextQty > stock) return;
      final copy = [...state];
      copy[existing] = CartLine(
        productId: line.productId,
        name: line.name,
        unitPrice: line.unitPrice,
        quantity: nextQty,
      );
      state = copy;
    } else {
      if (stock != null && stock < 1) return;
      state = [
        ...state,
        CartLine(
          productId: product.id,
          name: product.name,
          unitPrice: product.price,
          quantity: 1,
        ),
      ];
    }
  }

  void decrement(String productId) {
    final next = <CartLine>[];
    for (final line in state) {
      if (line.productId != productId) {
        next.add(line);
        continue;
      }
      if (line.quantity > 1) {
        next.add(CartLine(
          productId: line.productId,
          name: line.name,
          unitPrice: line.unitPrice,
          quantity: line.quantity - 1,
        ));
      }
    }
    state = next;
  }

  void removeLine(String productId) {
    state = [
      for (final line in state)
        if (line.productId != productId) line,
    ];
  }

  void clear() {
    state = [];
  }
}
