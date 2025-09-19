import 'dart:convert';

class Product {
  // Helper for encoding/decoding list of products for SharedPreferences
  static String encodeJsonList(List<Product> products) {
    return '[${products.map((p) => p.toJson()).map((m) => _encodeMap(m)).join(',')}]';
  }

  static List<dynamic> decodeJsonList(String jsonStr) {
    try {
      return jsonStr.isNotEmpty ? List<dynamic>.from(jsonDecode(jsonStr)) : [];
    } catch (_) {
      return [];
    }
  }

  static String _encodeMap(Map<String, dynamic> map) {
    return jsonEncode(map);
  }

  final String id; // رقم أو كود المنتج
  final String name; // اسم المنتج
  final String description; // وصف المنتج
  final String image; // الصورة الرئيسية

  final double price; // السعر
  final double? oldPrice; // السعر قبل الخصم (اختياري)
  final double? discount; // نسبة الخصم (اختياري)
  final double rate; // التقييم
  final int reviewsCount; // عدد التقييمات
  final String category; // التصنيف
  final String brand; // العلامة التجارية
  final bool inStock; // متوفر في المخزن أو لا
  final List<String> tags; // كلمات مفتاحية للبحث
  final DateTime createdAt; // تاريخ الإضافة
  final DateTime? updatedAt; // آخر تعديل
  final Map<String, dynamic>? variations; // ألوان، مقاسات ... إلخ

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.image,

    required this.price,
    this.oldPrice,
    this.discount,
    required this.rate,
    required this.reviewsCount,
    required this.category,
    required this.brand,
    required this.inStock,
    required this.tags,
    required this.createdAt,
    this.updatedAt,
    this.variations,
  });

  // تحويل من JSON
  factory Product.fromJson(Map<String, dynamic> json) {
    // Supabase returns snake_case by default, so handle both camelCase and snake_case
    String? getString(Map<String, dynamic> map, String key) {
      return map[key] ?? map[_toSnakeCase(key)];
    }

    dynamic getField(Map<String, dynamic> map, String key) {
      return map[key] ?? map[_toSnakeCase(key)];
    }

    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value);
      return null;
    }

    int toInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? toDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      return null;
    }

    List<String> toStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      return [];
    }

    Map<String, dynamic>? toMap(dynamic value) {
      if (value == null) return null;
      if (value is Map<String, dynamic>) return value;
      if (value is String) {
        try {
          return value.isNotEmpty
              ? Map<String, dynamic>.from(jsonDecode(value))
              : null;
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    return Product(
      id: getField(json, 'id')?.toString() ?? '',
      name: getString(json, 'name') ?? '',
      description: getString(json, 'description') ?? '',
      image: getString(json, 'image') ?? getString(json, 'image_url') ?? '',
      price: toDouble(getField(json, 'price')) ?? 0,
      oldPrice: toDouble(getField(json, 'oldPrice')),
      discount: toDouble(getField(json, 'discount')),
      rate: toDouble(getField(json, 'rate')) ?? 0,
      reviewsCount: toInt(getField(json, 'reviewsCount')),
      category: getString(json, 'category') ?? '',
      brand: getString(json, 'brand') ?? '',
      inStock: getField(json, 'inStock') ?? true,
      tags: toStringList(getField(json, 'tags')),
      createdAt: toDate(getField(json, 'createdAt')) ?? DateTime.now(),
      updatedAt: toDate(getField(json, 'updatedAt')),
      variations: toMap(getField(json, 'variations')),
    );
  }

  static String _toSnakeCase(String input) {
    return input.replaceAllMapped(
      RegExp(r'[A-Z]'),
      (Match m) => '_${m[0]!.toLowerCase()}',
    );
  }

  // تحويل لـ JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,

      'price': price,
      'oldPrice': oldPrice,
      'discount': discount,
      'rate': rate,
      'reviewsCount': reviewsCount,
      'category': category,
      'brand': brand,
      'inStock': inStock,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'variations': variations,
    };
  }

  static Product? findById(List<Product> products, String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (e) {
      return null; // product not found
    }
  }
}
 // final List<Product> products = [
  //   Product(
  //     id: "1",
  //     name: "Handbag",
  //     description: "Elegant leather handbag perfect for casual and formal use.",
  //     image: "assets/handbag.jpg",

  //     price: 28.0,
  //     oldPrice: 35.0,
  //     discount: 20.0,
  //     rate: 3.5,
  //     reviewsCount: 120,
  //     category: "Bags",
  //     brand: "FashionCo",
  //     inStock: true,
  //     tags: ["bag", "leather", "fashion"],
  //     createdAt: DateTime(2025, 1, 1),
  //     updatedAt: DateTime(2025, 1, 5),
  //     variations: {
  //       "color": ["black", "brown"],
  //       "size": ["small", "medium"],
  //     },
  //   ),
  //   Product(
  //     id: "2",
  //     name: "Hoodie",
  //     description: "Warm and comfortable hoodie for everyday wear.",
  //     image: "assets/hoddy.jpg",

  //     price: 58.0,
  //     oldPrice: 70.0,
  //     discount: 17.0,
  //     rate: 2.5,
  //     reviewsCount: 80,
  //     category: "Clothing",
  //     brand: "UrbanWear",
  //     inStock: true,
  //     tags: ["hoodie", "winter", "casual"],
  //     createdAt: DateTime(2025, 1, 2),
  //     updatedAt: DateTime(2025, 1, 6),
  //     variations: {
  //       "color": ["black", "grey"],
  //       "size": ["M", "L", "XL"],
  //     },
  //   ),
  //   Product(
  //     id: "3",
  //     name: "Headphones",
  //     description: "High-quality wireless headphones with noise cancellation.",
  //     image: "assets/headphones.jpg",

  //     price: 88.0,
  //     oldPrice: 110.0,
  //     discount: 20.0,
  //     rate: 4.5,
  //     reviewsCount: 200,
  //     category: "Electronics",
  //     brand: "SoundMax",
  //     inStock: true,
  //     tags: ["headphones", "audio", "wireless"],
  //     createdAt: DateTime(2025, 1, 3),
  //     updatedAt: DateTime(2025, 1, 7),
  //     variations: {
  //       "color": ["black", "white"],
  //     },
  //   ),
  //   Product(
  //     id: "4",
  //     name: "Classic Watch",
  //     description: "Stylish classic watch with leather strap.",
  //     image: "assets/classic watch.jpg",

  //     price: 88.0,
  //     oldPrice: 100.0,
  //     discount: 12.0,
  //     rate: 3.1,
  //     reviewsCount: 90,
  //     category: "Accessories",
  //     brand: "TimeLux",
  //     inStock: true,
  //     tags: ["watch", "leather", "classic"],
  //     createdAt: DateTime(2025, 1, 4),
  //     updatedAt: DateTime(2025, 1, 8),
  //     variations: {
  //       "color": ["black", "brown"],
  //     },
  //   ),
  //   Product(
  //     id: "5",
  //     name: "T-Shirt",
  //     description: "Soft cotton t-shirt, perfect for casual wear.",
  //     image: "assets/t-shirt.jpg",

  //     price: 88.0,
  //     oldPrice: 95.0,
  //     discount: 7.0,
  //     rate: 3.9,
  //     reviewsCount: 150,
  //     category: "Clothing",
  //     brand: "CottonWorld",
  //     inStock: true,
  //     tags: ["t-shirt", "casual", "cotton"],
  //     createdAt: DateTime(2025, 1, 5),
  //     updatedAt: DateTime(2025, 1, 9),
  //     variations: {
  //       "color": ["white", "blue"],
  //       "size": ["S", "M", "L"],
  //     },
  //   ),
  //   Product(
  //     id: "6",
  //     name: "Shoes",
  //     description: "Durable running shoes with breathable material.",
  //     image: "assets/shoes.jpg",

  //     price: 88.0,
  //     oldPrice: 120.0,
  //     discount: 27.0,
  //     rate: 2.7,
  //     reviewsCount: 60,
  //     category: "Footwear",
  //     brand: "RunFast",
  //     inStock: true,
  //     tags: ["shoes", "running", "sports"],
  //     createdAt: DateTime(2025, 1, 6),
  //     updatedAt: DateTime(2025, 1, 10),
  //     variations: {
  //       "color": ["black", "white"],
  //       "size": ["40", "41", "42", "43"],
  //     },
  //   ),
  //   Product(
  //     id: "7",
  //     name: "Jeans",
  //     description: "Comfortable slim-fit jeans with stretch fabric.",
  //     image: "assets/jeans.jpg",

  //     price: 88.0,
  //     oldPrice: 99.0,
  //     discount: 11.0,
  //     rate: 2.2,
  //     reviewsCount: 75,
  //     category: "Clothing",
  //     brand: "DenimPro",
  //     inStock: true,
  //     tags: ["jeans", "denim", "casual"],
  //     createdAt: DateTime(2025, 1, 7),
  //     updatedAt: DateTime(2025, 1, 11),
  //     variations: {
  //       "color": ["blue", "black"],
  //       "size": ["30", "32", "34"],
  //     },
  //   ),
  //   Product(
  //     id: "8",
  //     name: "Dress",
  //     description: "Elegant evening dress made from premium fabric.",
  //     image: "assets/dress.jpg",

  //     price: 88.0,
  //     oldPrice: 130.0,
  //     discount: 32.0,
  //     rate: 1.6,
  //     reviewsCount: 40,
  //     category: "Clothing",
  //     brand: "GlamourWear",
  //     inStock: true,
  //     tags: ["dress", "evening", "fashion"],
  //     createdAt: DateTime(2025, 1, 8),
  //     updatedAt: DateTime(2025, 1, 12),
  //     variations: {
  //       "color": ["red", "black"],
  //       "size": ["S", "M", "L"],
  //     },
  //   ),
  //   Product(
  //     id: "9",
  //     name: "Jacket",
  //     description: "Warm winter jacket with waterproof coating.",
  //     image: "assets/jacket.jpg",

  //     price: 88.0,
  //     oldPrice: 140.0,
  //     discount: 37.0,
  //     rate: 2.2,
  //     reviewsCount: 85,
  //     category: "Clothing",
  //     brand: "ColdShield",
  //     inStock: true,
  //     tags: ["jacket", "winter", "coat"],
  //     createdAt: DateTime(2025, 1, 9),
  //     updatedAt: DateTime(2025, 1, 13),
  //     variations: {
  //       "color": ["black", "grey"],
  //       "size": ["M", "L", "XL"],
  //     },
  //   ),
  //   Product(
  //     id: "10",
  //     name: "Earring",
  //     description: "Stylish silver earrings for all occasions.",
  //     image: "assets/earings.jpg",

  //     price: 88.0,
  //     oldPrice: 105.0,
  //     discount: 16.0,
  //     rate: 3.5,
  //     reviewsCount: 110,
  //     category: "Accessories",
  //     brand: "ShineBright",
  //     inStock: true,
  //     tags: ["earring", "silver", "jewelry"],
  //     createdAt: DateTime(2025, 1, 10),
  //     updatedAt: DateTime(2025, 1, 14),
  //     variations: {
  //       "color": ["silver"],
  //       "size": ["standard"],
  //     },
  //   ),
  // ];