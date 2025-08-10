class Product {
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
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
    
      price: (json['price'] ?? 0).toDouble(),
      oldPrice: json['oldPrice'] != null ? (json['oldPrice']).toDouble() : null,
      discount: json['discount'] != null ? (json['discount']).toDouble() : null,
      rate: (json['rate'] ?? 0).toDouble(),
      reviewsCount: json['reviewsCount'] ?? 0,
      category: json['category'] ?? '',
      brand: json['brand'] ?? '',
      inStock: json['inStock'] ?? true,
      tags: List<String>.from(json['tags'] ?? []),
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      variations: json['variations'],
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
}
