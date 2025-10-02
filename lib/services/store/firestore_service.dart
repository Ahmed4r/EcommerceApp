import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/model/product_model.dart';

class FirestoreService {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  late final CollectionReference productsCollection;
  late final CollectionReference usersCollection;

  FirestoreService() {
    productsCollection = firestore.collection('products');
    usersCollection = firestore.collection('users');
  }
  // add users
  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(userData['uid']).set(userData);
    } catch (e) {
      log(e.toString());
    }
  }

  // get orders
  Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> orders = [];

      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        orderData['id'] = doc.id;

        // Fetch order items
        final itemsSnapshot = await firestore
            .collection('orders')
            .doc(doc.id)
            .collection('items')
            .get();

        orderData['items'] = itemsSnapshot.docs
            .map((itemDoc) => {'id': itemDoc.id, ...itemDoc.data()})
            .toList();

        orders.add(orderData);
      }

      return orders;
    } catch (e) {
      log('Error fetching all orders: $e');
      return [];
    }
  }

  // get all orders count
  Future<int> getOrdersCount() async {
    try {
      log('Fetching orders count from Firestore...');

      // Use count() aggregation query for better performance
      final aggregate = await firestore
          .collection('orders')
          .count()
          .get()
          .timeout(const Duration(seconds: 15));

      final orderCount = aggregate.count ?? 0;
      log('Total orders count: $orderCount');
      return orderCount;
    } on FirebaseException catch (e) {
      log('Firebase error fetching orders count: ${e.code} - ${e.message}');

      // If count() is not available or fails, fallback to size query
      try {
        log('Falling back to snapshot size query...');
        final snapshot = await firestore
            .collection('orders')
            .limit(1) // Only need to check if any orders exist
            .get()
            .timeout(const Duration(seconds: 10));

        if (snapshot.docs.isEmpty) {
          log('No orders found in collection');
          return 0;
        }

        // If orders exist but count() failed, we can't get accurate count efficiently
        // Return -1 to indicate count unavailable but orders exist
        log('Orders exist but count unavailable, returning indicator value');
        return -1;
      } catch (fallbackError) {
        log('Fallback query also failed: $fallbackError');
        return 0;
      }
    } catch (e) {
      log('Unexpected error fetching orders count: $e');
      return 0;
    }
  }

  // Alternative method that gets accurate count but less efficient for large collections
  Future<int> getOrdersCountAccurate() async {
    try {
      log('Fetching accurate orders count using snapshot...');

      final snapshot = await firestore
          .collection('orders')
          .get()
          .timeout(const Duration(seconds: 30));

      final orderCount = snapshot.size;
      log('Accurate orders count: $orderCount');
      return orderCount;
    } catch (e) {
      log('Error fetching accurate orders count: $e');
      return 0;
    }
  }

  // Check if orders collection has any documents (lightweight check)
  Future<bool> hasOrders() async {
    try {
      final snapshot = await firestore
          .collection('orders')
          .limit(1)
          .get()
          .timeout(const Duration(seconds: 10));

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      log('Error checking if orders exist: $e');
      return false;
    }
  }

  // update user
  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    try {
      await usersCollection.doc(uid).update(userData);

      // Save phone to SharedPreferences if it's being updated
      if (userData.containsKey('phone')) {
        await _savePhoneToSharedPrefs(userData['phone'] ?? '');
      }
    } catch (e) {
      log('Error updating user: ${e.toString()}');
    }
  }

  Future<String> getUserPhone() async {
    try {
      // Get current user's UID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        log('No authenticated user found');
        return await _getPhoneFromSharedPrefs();
      }

      // Get user document using the current user's UID
      final userDoc = await usersCollection.doc(currentUser.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        final phone = data['phone'] ?? '';

        // Save to SharedPreferences for offline access
        if (phone.isNotEmpty) {
          await _savePhoneToSharedPrefs(phone);
        }

        return phone;
      } else {
        log('User document does not exist in Firestore');
        return await _getPhoneFromSharedPrefs();
      }
    } catch (e) {
      log('Error getting user phone: ${e.toString()}');
      return await _getPhoneFromSharedPrefs();
    }
  }

  // Helper method to get phone from SharedPreferences as fallback
  Future<String> _getPhoneFromSharedPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('phone') ?? '';
    } catch (e) {
      log('Error getting phone from SharedPreferences: ${e.toString()}');
      return '';
    }
  }

  // Helper method to save phone to SharedPreferences
  Future<void> _savePhoneToSharedPrefs(String phone) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('phone', phone);
    } catch (e) {
      log('Error saving phone to SharedPreferences: ${e.toString()}');
    }
  }

  // getData
  Future<List<Product>> getProducts() async {
    try {
      final QuerySnapshot snapshot = await productsCollection.get().timeout(
        const Duration(seconds: 10),
      ); // Add timeout

      if (snapshot.docs.isEmpty) {
        log('No products found in Firestore');
        return [];
      }

      return snapshot.docs
          .map((doc) {
            try {
              return Product.fromJson(doc.data() as Map<String, dynamic>);
            } catch (e) {
              log('Error parsing product ${doc.id}: $e');
              return null;
            }
          })
          .where((product) => product != null)
          .cast<Product>()
          .toList();
    } catch (e) {
      log('Error fetching products: $e');
      return [];
    }
  }

  Future<int> getTotalUsers() async {
    try {
      final snapshot = await usersCollection.get();
      return snapshot.size;
    } catch (e) {
      log('Error fetching total users: $e');
      return 0;
    }
  }

  // Calculate total revenue from all completed orders
  Future<double> getTotalRevenue() async {
    try {
      log('Calculating total revenue from all orders...');

      // Get all orders and filter on client side to avoid composite index
      final snapshot = await firestore
          .collection('orders')
          .get()
          .timeout(const Duration(seconds: 30));

      double totalRevenue = 0.0;
      int completedOrders = 0;

      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        final status = orderData['status'] as String?;
        final amount = orderData['totalAmount'];

        // Only count completed or delivered orders
        if (status != null &&
            (status.toLowerCase() == 'completed' ||
                status.toLowerCase() == 'delivered')) {
          if (amount != null) {
            // Handle different number types
            if (amount is num) {
              totalRevenue += amount.toDouble();
              completedOrders++;
            } else if (amount is String) {
              final parsedAmount = double.tryParse(amount) ?? 0.0;
              totalRevenue += parsedAmount;
              if (parsedAmount > 0) completedOrders++;
            }
          }
        }
      }

      log(
        'Total revenue calculated: \$${totalRevenue.toStringAsFixed(2)} from $completedOrders completed orders',
      );
      return totalRevenue;
    } catch (e) {
      log('Error calculating total revenue: $e');
      return 0.0;
    }
  }

  // Calculate revenue for a specific time period
  Future<double> getRevenueForPeriod({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      log(
        'Calculating revenue from ${startDate.toIso8601String()} to ${endDate.toIso8601String()}',
      );

      // Get all orders and filter on client side to avoid composite index
      final snapshot = await firestore
          .collection('orders')
          .get()
          .timeout(const Duration(seconds: 30));

      double periodRevenue = 0.0;
      int ordersInPeriod = 0;

      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        final status = orderData['status'] as String?;
        final createdAt = orderData['createdAt'];
        final amount = orderData['totalAmount'];

        // Check if order is completed/delivered
        if (status != null &&
            (status.toLowerCase() == 'completed' ||
                status.toLowerCase() == 'delivered')) {
          // Check if order is in the specified date range
          DateTime? orderDate;
          if (createdAt is Timestamp) {
            orderDate = createdAt.toDate();
          } else if (createdAt is String) {
            orderDate = DateTime.tryParse(createdAt);
          }

          if (orderDate != null &&
              orderDate.isAfter(
                startDate.subtract(const Duration(seconds: 1)),
              ) &&
              orderDate.isBefore(endDate.add(const Duration(seconds: 1)))) {
            if (amount != null) {
              if (amount is num) {
                periodRevenue += amount.toDouble();
                ordersInPeriod++;
              } else if (amount is String) {
                final parsedAmount = double.tryParse(amount) ?? 0.0;
                periodRevenue += parsedAmount;
                if (parsedAmount > 0) ordersInPeriod++;
              }
            }
          }
        }
      }

      log(
        'Revenue for period: \$${periodRevenue.toStringAsFixed(2)} from $ordersInPeriod orders',
      );
      return periodRevenue;
    } catch (e) {
      log('Error calculating period revenue: $e');
      return 0.0;
    }
  }

  // Get today's revenue
  Future<double> getTodayRevenue() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getRevenueForPeriod(startDate: startOfDay, endDate: endOfDay);
  }

  // Get this month's revenue
  Future<double> getMonthlyRevenue() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getRevenueForPeriod(startDate: startOfMonth, endDate: endOfMonth);
  }

  // Get revenue statistics (total, today, this month)
  Future<Map<String, double>> getRevenueStats() async {
    try {
      log('Fetching comprehensive revenue statistics...');

      final results = await Future.wait([
        getTotalRevenue(),
        getTodayRevenue(),
        getMonthlyRevenue(),
      ]);

      return {'total': results[0], 'today': results[1], 'monthly': results[2]};
    } catch (e) {
      log('Error fetching revenue stats: $e');
      return {'total': 0.0, 'today': 0.0, 'monthly': 0.0};
    }
  }

  // Get revenue breakdown by status
  Future<Map<String, double>> getRevenueByStatus() async {
    try {
      log('Calculating revenue breakdown by order status...');

      final snapshot = await firestore
          .collection('orders')
          .get()
          .timeout(const Duration(seconds: 30));

      Map<String, double> revenueByStatus = {
        'pending': 0.0,
        'confirmed': 0.0,
        'processing': 0.0,
        'shipped': 0.0,
        'delivered': 0.0,
        'completed': 0.0,
        'cancelled': 0.0,
      };

      Map<String, int> orderCountByStatus = {
        'pending': 0,
        'confirmed': 0,
        'processing': 0,
        'shipped': 0,
        'delivered': 0,
        'completed': 0,
        'cancelled': 0,
      };

      for (var doc in snapshot.docs) {
        final orderData = doc.data();
        final status = (orderData['status'] ?? 'pending')
            .toString()
            .toLowerCase();
        final amount = orderData['totalAmount'];

        if (amount != null) {
          double orderAmount = 0.0;
          if (amount is num) {
            orderAmount = amount.toDouble();
          } else if (amount is String) {
            orderAmount = double.tryParse(amount) ?? 0.0;
          }

          revenueByStatus[status] =
              (revenueByStatus[status] ?? 0.0) + orderAmount;
          orderCountByStatus[status] = (orderCountByStatus[status] ?? 0) + 1;
        }
      }

      log('Revenue by status: $revenueByStatus');
      log('Orders count by status: $orderCountByStatus');
      return revenueByStatus;
    } catch (e) {
      log('Error calculating revenue by status: $e');
      return {};
    }
  }

  // Debug method to check order data structure
  Future<void> debugOrdersData() async {
    try {
      log('=== DEBUGGING ORDERS DATA ===');

      final snapshot = await firestore
          .collection('orders')
          .limit(5) // Only check first 5 orders
          .get();

      log('Total orders found: ${snapshot.docs.length}');

      for (int i = 0; i < snapshot.docs.length; i++) {
        final doc = snapshot.docs[i];
        final data = doc.data();

        log('Order ${i + 1} (ID: ${doc.id}):');
        log(
          '  - Status: ${data['status']} (type: ${data['status'].runtimeType})',
        );
        log(
          '  - TotalAmount: ${data['totalAmount']} (type: ${data['totalAmount'].runtimeType})',
        );
        log(
          '  - CreatedAt: ${data['createdAt']} (type: ${data['createdAt'].runtimeType})',
        );
        log('  - UserId: ${data['userId']}');
        log('  - All fields: ${data.keys.toList()}');
        log('  ---');
      }

      log('=== END DEBUG ===');
    } catch (e) {
      log('Error debugging orders data: $e');
    }
  }
}
