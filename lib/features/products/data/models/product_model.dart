import '../../domain/entities/product_entity.dart';

class ProductModel {
  ProductModel({
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

  static int? _parseInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    return int.tryParse(raw.toString());
  }

  static bool _parseBool(dynamic raw, {bool fallback = true}) {
    if (raw is bool) return raw;
    if (raw is num) return raw != 0;
    final s = raw?.toString().toLowerCase().trim();
    if (s == 'false' || s == '0' || s == 'inactive' || s == 'no') {
      return false;
    }
    if (s == 'true' || s == '1' || s == 'active' || s == 'yes') {
      return true;
    }
    return fallback;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawPrice = json['price'];
    double parsedPrice = 0;
    if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else if (rawPrice != null) {
      parsedPrice = double.tryParse(rawPrice.toString()) ?? 0;
    }

    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      sku: json['sku']?.toString() ?? json['code']?.toString(),
      price: parsedPrice,
      categoryId: json['categoryId']?.toString() ??
          json['category_id']?.toString() ??
          '',
      stock: _parseInt(json['stock'] ?? json['quantity']),
      minStock: _parseInt(
        json['minStock'] ??
            json['min_stock'] ??
            json['minimumStock'] ??
            json['stockMin'],
      ),
      isActive: _parseBool(
        json['isActive'] ?? json['is_active'] ?? json['active'],
        fallback: true,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (description != null && description!.isNotEmpty) 'description': description,
      if (sku != null && sku!.isNotEmpty) 'sku': sku,
      'price': price,
      'categoryId': categoryId,
      if (stock != null) 'stock': stock,
      if (minStock != null) 'minStock': minStock,
      'isActive': isActive,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      sku: sku,
      price: price,
      categoryId: categoryId,
      stock: stock,
      minStock: minStock,
      isActive: isActive,
    );
  }
}
