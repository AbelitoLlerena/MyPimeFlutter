class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    this.sku,
    required this.price,
    required this.categoryId,
    this.stock,
    this.minStock,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String? description;
  final String? sku;
  final double price;
  final String categoryId;
  final int? stock;
  final int? minStock;
  final bool isActive;
}
