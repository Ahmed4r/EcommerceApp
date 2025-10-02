import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shop/model/address_model.dart';
import 'package:shop/screens/cart/cart_screen.dart';

class OrdersService {
  OrdersService._();
  static final OrdersService instance = OrdersService._();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createOrder({
    required AddressModel? address,
    required String paymentMethod,
    required double total,
    required List<CartItem> items,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    try {
      // Create order document
      final orderRef = await _firestore.collection('orders').add({
        'userId': userId,
        'status': 'pending',
        'totalAmount': total,
        'paymentMethod': paymentMethod,
        'address': address?.toJson(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final orderId = orderRef.id;

      // Create order items subcollection
      if (items.isNotEmpty) {
        final batch = _firestore.batch();

        for (var item in items) {
          final itemRef = _firestore
              .collection('orders')
              .doc(orderId)
              .collection('items')
              .doc();

          batch.set(itemRef, {
            'productId': item.product.id,
            'productData': item.product.toJson(),
            'quantity': item.quantity,
            'price': item.product.price,
            'totalPrice': item.product.price * item.quantity,
          });
        }

        await batch.commit();
      }

      return orderId;
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  

  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    final userId = _auth.currentUser?.uid;
    print('🔍 Current user ID: $userId');
    if (userId == null) {
      print('❌ User not authenticated');
      throw Exception('Not authenticated');
    }

    try {
      print('📡 Fetching orders from Firestore...');
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          // Removed orderBy to avoid composite index requirement
          // Will sort on client side instead
          .get();

      print('📦 Found ${snapshot.docs.length} orders');
      List<Map<String, dynamic>> orders = [];

      for (var doc in snapshot.docs) {
        print('🔄 Processing order: ${doc.id}');
        final orderData = doc.data();
        orderData['id'] = doc.id;

        // Fetch order items
        final itemsSnapshot = await _firestore
            .collection('orders')
            .doc(doc.id)
            .collection('items')
            .get();

        print('📋 Order ${doc.id} has ${itemsSnapshot.docs.length} items');
        orderData['items'] = itemsSnapshot.docs
            .map((itemDoc) => {'id': itemDoc.id, ...itemDoc.data()})
            .toList();

        orders.add(orderData);
      }

      // Client-side sorting by createdAt (newest first)
      orders.sort((a, b) {
        final aTime =
            (a['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
        final bTime =
            (b['createdAt'] as Timestamp?)?.toDate() ?? DateTime(1970);
        return bTime.compareTo(aTime); // Descending order
      });

      print('✅ Successfully fetched and sorted ${orders.length} orders');
      return orders;
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating order status: $e');
      throw Exception('Failed to update order status: $e');
    }
  }

  Stream<String?> streamOrderStatus(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots().map((
      snapshot,
    ) {
      if (snapshot.exists) {
        return snapshot.data()?['status'] as String?;
      }
      return null;
    });
  }

  Future<Map<String, dynamic>?> getOrderDetails(String orderId) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) return null;

      final orderData = orderDoc.data()!;
      orderData['id'] = orderDoc.id;

      // Fetch order items
      final itemsSnapshot = await _firestore
          .collection('orders')
          .doc(orderId)
          .collection('items')
          .get();

      orderData['items'] = itemsSnapshot.docs
          .map((itemDoc) => {'id': itemDoc.id, ...itemDoc.data()})
          .toList();

      return orderData;
    } catch (e) {
      print('Error getting order details: $e');
      return null;
    }
  }

  // Method to cancel an order (if status is still pending)
  Future<bool> cancelOrder(String orderId) async {
    try {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();

      if (!orderDoc.exists) return false;

      final orderData = orderDoc.data()!;
      final currentStatus = orderData['status'] as String?;

      // Only allow cancellation if order is pending
      if (currentStatus == 'pending') {
        await updateOrderStatus(orderId, 'cancelled');
        return true;
      }

      return false;
    } catch (e) {
      print('Error cancelling order: $e');
      return false;
    }
  }
}
