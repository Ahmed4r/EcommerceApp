import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shop/model/address_model.dart';
import 'package:shop/screens/cart/cart_screen.dart';

class OrdersService {
  OrdersService._();
  static final OrdersService instance = OrdersService._();
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<dynamic> createOrder({
    required AddressModel?
    address, // kept for future extension; not stored in schema
    required String
    paymentMethod, // kept for future extension; not stored in schema
    required double total,
    required List<CartItem> items,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    // Create order row
    final order = await _supabase
        .from('orders')
        .insert({'user_id': userId, 'status': 'pending', 'total_amount': total})
        .select('id')
        .single();

    final orderId = order['id'];

    // Insert order items
    if (items.isNotEmpty) {
      final rows = items
          .map(
            (e) => {
              'order_id': orderId,
              'product_id': e.product.id,
              'quantity': e.quantity,
              'price': e.product.price,
            },
          )
          .toList();
      await _supabase.from('order_items').insert(rows);
    }

    return orderId;
  }

  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    final data = await _supabase
        .from('orders')
        .select()
        .order('created_at', ascending: false);

    final list = (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    // Attach items for each order
    for (final o in list) {
      try {
        final items = await _supabase
            .from('order_items')
            .select('product_id, quantity, price')
            .eq('order_id', o['id']);
        o['items'] = items;
      } catch (_) {
        o['items'] = [];
      }
    }
    return list;
  }

  Future<List<Map<String, dynamic>>> fetchMyOrders() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('Not authenticated');
    }

    final data = await _supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final list = (data as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();

    for (final o in list) {
      try {
        final items = await _supabase
            .from('order_items')
            .select('product_id, quantity, price')
            .eq('order_id', o['id']);
        o['items'] = items;
      } catch (_) {
        o['items'] = [];
      }
    }
    return list;
  }

  Future<void> updateOrderStatus(dynamic orderId, String status) async {
    await _supabase.from('orders').update({'status': status}).eq('id', orderId);
  }

  Stream<String> streamOrderStatus(dynamic orderId) {
    final controller = StreamController<String>.broadcast();

    final channel = _supabase
        .channel('orders_status_$orderId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'orders',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: orderId,
          ),
          callback: (payload) {
            try {
              final newRec = payload.newRecord as Map<String, dynamic>?;
              final status = newRec?['status'] as String?;
              if (status != null) controller.add(status);
            } catch (_) {}
          },
        )
        .subscribe();

    // Seed current status once
    () async {
      try {
        final row = await _supabase
            .from('orders')
            .select('status')
            .eq('id', orderId)
            .single();
        final status = row['status'] as String?;
        if (status != null) controller.add(status);
      } catch (_) {}
    }();

    controller.onCancel = () {
      _supabase.removeChannel(channel);
    };

    return controller.stream;
  }
}
