import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/orders_service.dart';
import 'order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  bool _isLoading = false;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      print('🔍 Loading orders...');

      // Check authentication state
      final currentUser = FirebaseAuth.instance.currentUser;
      print('👤 Current user: ${currentUser?.uid ?? 'Not authenticated'}');
      print('📧 User email: ${currentUser?.email ?? 'No email'}');

      final orders = await OrdersService.instance.fetchMyOrders();
      print('📦 Orders loaded: ${orders.length} orders found');
      if (orders.isNotEmpty) {
        print('📋 First order: ${orders[0]}');
      }
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading orders: $e');
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load orders: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Debug method to create test orders
  Future<void> _createTestOrder() async {
    try {
      print('🔧 Creating test order...');
      final orderId = await OrdersService.instance.createOrder(
        address: null, // Using null for testing
        paymentMethod: 'Test Payment',
        total: 99.99,
        items: [], // Empty items for testing
      );
      print('✅ Test order created with ID: $orderId');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Test order created: $orderId'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Refresh orders list
      _loadOrders();
    } catch (e) {
      print('❌ Failed to create test order: $e');
      _showErrorSnackBar('Failed to create test order: $e');
    }
  }

  // Debug method to directly query Firestore
  Future<void> _debugFirestore() async {
    try {
      print('🔧 Debug: Checking Firestore directly...');
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No current user');
        return;
      }

      // Direct Firestore query
      final snapshot = await FirebaseFirestore.instance
          .collection('orders')
          .get();

      print('📊 Total orders in collection: ${snapshot.docs.length}');

      final userOrders = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      print('👤 User orders: ${userOrders.docs.length}');

      for (var doc in userOrders.docs) {
        print('📋 Order: ${doc.id} - ${doc.data()}');
      }
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }

  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == 'all') return _orders;
    return _orders
        .where((order) => order['status'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            color: theme.iconTheme.color,
            size: 20.sp,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Orders',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          GestureDetector(
            onTap: _loadOrders,
            onLongPress: _debugFirestore, // Long press for debug
            child: Container(
              padding: EdgeInsets.all(8.w),
              child: FaIcon(
                FontAwesomeIcons.rotateRight,
                color: theme.iconTheme.color,
                size: 18.sp,
              ),
            ),
          ),
          //  Debug button - for testing only
          // IconButton(
          //   icon: FaIcon(
          //     FontAwesomeIcons.plus,
          //     color: theme.iconTheme.color,
          //     size: 18.sp,
          //   ),
          //   onPressed: _createTestOrder,
          // ),
          SizedBox(width: 8.w),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.h),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(25.r),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(
                0.6,
              ),
              labelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'All'),
                Tab(text: 'Pending'),
                Tab(text: 'Processing'),
                Tab(text: 'Shipped'),
                Tab(text: 'Delivered'),
              ],
              onTap: (index) {
                setState(() {
                  switch (index) {
                    case 0:
                      _selectedFilter = 'all';
                      break;
                    case 1:
                      _selectedFilter = 'pending';
                      break;
                    case 2:
                      _selectedFilter = 'processing';
                      break;
                    case 3:
                      _selectedFilter = 'shipped';
                      break;
                    case 4:
                      _selectedFilter = 'delivered';
                      break;
                  }
                });
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadOrders,
              child: _filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.all(16.w),
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.receipt,
            size: 80.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Orders Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            _selectedFilter == 'all'
                ? 'You haven\'t placed any orders yet.\nTry placing an order from the checkout.'
                : 'No ${_selectedFilter} orders found.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            icon: FaIcon(FontAwesomeIcons.rotateRight, size: 16.sp),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final theme = Theme.of(context);

    final createdAt = order['createdAt'] as Timestamp?;
    final date = createdAt?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);

    final status = order['status'] as String? ?? 'pending';
    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final items = order['items'] as List<dynamic>? ?? [];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => OrderDetailsScreen(orderId: order['id']),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16.r),
          child: Container(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Order Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order #${order['id'].substring(0, 8).toUpperCase()}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$formattedDate at $formattedTime',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(
                                0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStatusChip(status),
                  ],
                ),

                SizedBox(height: 16.h),

                // Order Items Preview
                if (items.isNotEmpty) ...[
                  Row(
                    children: [
                      FaIcon(
                        FontAwesomeIcons.box,
                        size: 16.sp,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${items.length} item${items.length > 1 ? 's' : ''}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                ],

                // Total Amount
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderDetailsScreen(orderId: order['id']),
                            ),
                          );
                        },
                        icon: FaIcon(FontAwesomeIcons.eye, size: 14.sp),
                        label: Text(
                          'View Details',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          side: BorderSide(
                            color: theme.colorScheme.primary.withOpacity(0.5),
                          ),
                        ),
                      ),
                    ),
                    if (status == 'pending') ...[
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _cancelOrder(order['id']),
                          icon: FaIcon(FontAwesomeIcons.xmark, size: 14.sp),
                          label: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color getStatusColor() {
      switch (status.toLowerCase()) {
        case 'pending':
          return Colors.orange;
        case 'processing':
          return Colors.blue;
        case 'shipped':
          return Colors.purple;
        case 'delivered':
          return Colors.green;
        case 'cancelled':
          return Colors.red;
        default:
          return Colors.grey;
      }
    }

    IconData getStatusIcon() {
      switch (status.toLowerCase()) {
        case 'pending':
          return FontAwesomeIcons.clock;
        case 'processing':
          return FontAwesomeIcons.gear;
        case 'shipped':
          return FontAwesomeIcons.truck;
        case 'delivered':
          return FontAwesomeIcons.circleCheck;
        case 'cancelled':
          return FontAwesomeIcons.circleXmark;
        default:
          return FontAwesomeIcons.question;
      }
    }

    final statusColor = getStatusColor();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(getStatusIcon(), size: 12.sp, color: statusColor),
          SizedBox(width: 6.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text('Are you sure you want to cancel this order?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await OrdersService.instance.cancelOrder(orderId);
        if (success) {
          _loadOrders(); // Refresh the orders list
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Order cancelled successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else {
          _showErrorSnackBar('Failed to cancel order');
        }
      } catch (e) {
        _showErrorSnackBar('Error cancelling order: $e');
      }
    }
  }
}
