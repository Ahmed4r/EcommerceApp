import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'address_model.dart';
import 'product_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final AddressModel address;
  final String paymentMethod;
  final double total;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.paymentMethod,
    required this.total,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromMap(item))
              .toList() ??
          [],
      address: AddressModel.fromJson(data['address'] ?? {}),
      paymentMethod: data['paymentMethod'] ?? '',
      total: (data['total'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'address': address.toJson(),
      'paymentMethod': paymentMethod,
      'total': total,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    AddressModel? address,
    String? paymentMethod,
    double? total,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      items: items ?? this.items,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      total: total ?? this.total,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderItem {
  final Product product;
  final int quantity;

  OrderItem({required this.product, required this.quantity});

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      product: Product.fromJson(map['product'] ?? {}),
      quantity: map['quantity']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'product': product.toJson(), 'quantity': quantity};
  }
}

// Extension to add icon property to AddressModel if not already present
extension AddressModelExtension on AddressModel {
  IconData get icon {
    switch (iconName?.toLowerCase()) {
      case 'home':
        return FontAwesomeIcons.house;
      case 'work':
        return FontAwesomeIcons.briefcase;
      case 'location_on':
        return FontAwesomeIcons.locationDot;
      default:
        return FontAwesomeIcons.mapPin;
    }
  }
}
