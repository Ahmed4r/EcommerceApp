import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shop/services/store/firestore_service.dart';

class OrdersManagementPage extends StatefulWidget {
  static const String routeName = '/admin/orders';
  const OrdersManagementPage({super.key});

  @override
  State<OrdersManagementPage> createState() => _OrdersManagementPageState();
}

class _OrdersManagementPageState extends State<OrdersManagementPage> {
  final FirestoreService firestoreService = FirestoreService();
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> filteredOrders = [];
  bool isLoading = true;
  String selectedStatus = 'All';
  final TextEditingController searchController = TextEditingController();

  final List<String> orderStatuses = [
    'All',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'completed',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        isLoading = true;
      });

      log('Fetching all orders for admin management...');
      final fetchedOrders = await firestoreService.fetchAllOrders();

      setState(() {
        orders = fetchedOrders;
        filteredOrders = fetchedOrders;
        isLoading = false;
      });

      log('Loaded ${orders.length} orders for management');
    } catch (e) {
      log('Error fetching orders: $e');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading orders: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterOrders() {
    setState(() {
      filteredOrders = orders.where((order) {
        final matchesStatus =
            selectedStatus == 'All' || order['status'] == selectedStatus;
        final matchesSearch =
            searchController.text.isEmpty ||
            order['id'].toString().toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            (order['userId'] ?? '').toString().toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
        return matchesStatus && matchesSearch;
      }).toList();
    });
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      await firestoreService.firestore.collection('orders').doc(orderId).update(
        {'status': newStatus, 'updatedAt': DateTime.now().toIso8601String()},
      );

      // Update local state
      setState(() {
        final orderIndex = orders.indexWhere((order) => order['id'] == orderId);
        if (orderIndex != -1) {
          orders[orderIndex]['status'] = newStatus;
        }
        _filterOrders();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      log('Error updating order status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Text(
          'Orders Management',
          style: GoogleFonts.sen(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).appBarTheme.titleTextStyle?.color,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Orders',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by Order ID or User ID',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              searchController.clear();
                              _filterOrders();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) => _filterOrders(),
                ),
                const SizedBox(height: 12),
                // Status Filter
                Row(
                  children: [
                    Text(
                      'Filter by Status:',
                      style: GoogleFonts.sen(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedStatus,
                        isExpanded: true,
                        items: orderStatuses.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(
                              status,
                              style: GoogleFonts.sen(fontSize: 14.sp),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                          _filterOrders();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 64.r,
                          color: Colors.grey[400],
                        ),
                        SizedBox(height: 16.h),
                        Text(
                          'No orders found',
                          style: GoogleFonts.sen(
                            fontSize: 18.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (selectedStatus != 'All' ||
                            searchController.text.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                selectedStatus = 'All';
                                searchController.clear();
                              });
                              _filterOrders();
                            },
                            child: Text(
                              'Clear Filters',
                              style: GoogleFonts.sen(
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      return _buildOrderCard(order);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] ?? 'pending';
    final orderId = order['id'] ?? 'Unknown';
    final userId = order['userId'] ?? 'Unknown';
    final totalAmount = order['totalAmount'] ?? 0.0;
    final createdAt = order['createdAt'];
    final items = order['items'] as List<dynamic>? ?? [];

    // Parse date
    String dateStr = 'Unknown Date';
    if (createdAt != null) {
      try {
        DateTime date;
        if (createdAt is String) {
          date = DateTime.parse(createdAt);
        } else {
          date = createdAt.toDate();
        }
        dateStr = DateFormat('MMM dd, yyyy - HH:mm').format(date);
      } catch (e) {
        dateStr = createdAt.toString();
      }
    }

    // Status color
    Color statusColor = _getStatusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${orderId.length > 10 ? orderId.substring(0, 10) + '...' : orderId}',
                        style: GoogleFonts.sen(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'User: ${userId.length > 15 ? userId.substring(0, 15) + '...' : userId}',
                        style: GoogleFonts.sen(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: GoogleFonts.sen(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Order Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount: \$${totalAmount.toString()}',
                        style: GoogleFonts.sen(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.green[700],
                        ),
                      ),
                      Text(
                        'Date: $dateStr',
                        style: GoogleFonts.sen(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Items: ${items.length}',
                        style: GoogleFonts.sen(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // Status Update Button
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (newStatus) {
                    _updateOrderStatus(orderId, newStatus);
                  },
                  itemBuilder: (context) {
                    return orderStatuses
                        .where((s) => s != 'All' && s != status)
                        .map((status) {
                          return PopupMenuItem<String>(
                            value: status,
                            child: Text(
                              'Mark as ${status.toUpperCase()}',
                              style: GoogleFonts.sen(),
                            ),
                          );
                        })
                        .toList();
                  },
                ),
              ],
            ),
            // Items Preview
            if (items.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Items:',
                style: GoogleFonts.sen(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              ...items
                  .take(2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(left: 8, bottom: 2),
                      child: Text(
                        '• ${item['productName'] ?? 'Unknown'} (${item['quantity'] ?? 1}x)',
                        style: GoogleFonts.sen(
                          fontSize: 11.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
              if (items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '... and ${items.length - 2} more items',
                    style: GoogleFonts.sen(
                      fontSize: 11.sp,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
