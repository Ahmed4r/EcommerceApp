import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/services/orders_service.dart';

class OrdersPage extends StatefulWidget {
  static const String routeName = '/orders';

  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  late Future<List<Map<String, dynamic>>> _future;
  StreamSubscription? _ordersSubscription;

  @override
  void initState() {
    super.initState();
    _future = OrdersService.instance.fetchMyOrders();
    _subscribeToOrdersUpdates();
  }

  void _subscribeToOrdersUpdates() {
    // Since Firebase doesn't have built-in realtime for complex queries,
    // we'll use a simple timer-based refresh for now
    // In a production app, you might want to use Firebase Functions with Push Notifications
    Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted) {
        setState(() {
          _future = OrdersService.instance.fetchMyOrders();
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'My Orders',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
            color: Colors.black,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Text(
                  'Failed to load orders: ${snap.error}',
                  style: GoogleFonts.cairo(fontSize: 16.sp),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final orders = snap.data ?? [];
          if (orders.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64.sp,
                      color: Colors.grey[400],
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "You don't have any orders yet.",
                      style: GoogleFonts.cairo(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Start shopping to see your orders here!",
                      style: GoogleFonts.cairo(
                        fontSize: 14.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _future = OrdersService.instance.fetchMyOrders();
              });
              await _future;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(12.r),
              itemBuilder: (context, index) {
                final order = orders[index];
                final id = order['id'] as String;
                final status = (order['status'] ?? 'pending') as String;
                final total = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;
                final items = (order['items'] as List?) ?? const [];

                // Parse timestamp
                final createdAt = order['createdAt'];
                String dateString = '';
                if (createdAt != null) {
                  try {
                    final timestamp = createdAt.toDate();
                    dateString =
                        '${timestamp.day}/${timestamp.month}/${timestamp.year}';
                  } catch (e) {
                    dateString = 'Recent';
                  }
                }

                return _OrderTile(
                  orderId: id,
                  status: status,
                  total: total,
                  itemCount: items.length,
                  items: items,
                  date: dateString,
                  onTap: () => _showOrderDetails(context, order),
                );
              },
              separatorBuilder: (_, __) => SizedBox(height: 8.h),
              itemCount: orders.length,
            ),
          );
        },
      ),
    );
  }

  void _showOrderDetails(BuildContext context, Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OrderDetailsModal(order: order),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final String orderId;
  final String status;
  final double total;
  final int itemCount;
  final List<dynamic> items;
  final String date;
  final VoidCallback onTap;

  const _OrderTile({
    required this.orderId,
    required this.status,
    required this.total,
    required this.itemCount,
    required this.items,
    required this.date,
    required this.onTap,
  });

  Color _colorFor(String s) {
    switch (s.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'shipped':
        return Colors.blue;
      case 'delivered':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _colorFor(status);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${orderId.substring(0, 8)}...',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.w700,
                          fontSize: 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      '\$${total.toStringAsFixed(2)}',
                      style: GoogleFonts.cairo(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: GoogleFonts.cairo(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '$itemCount items',
                      style: GoogleFonts.cairo(
                        color: Colors.grey[600],
                        fontSize: 14.sp,
                      ),
                    ),
                    const Spacer(),
                    if (date.isNotEmpty)
                      Text(
                        date,
                        style: GoogleFonts.cairo(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderDetailsModal extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderDetailsModal({required this.order});

  @override
  Widget build(BuildContext context) {
    final items = order['items'] as List<dynamic>? ?? [];
    final status = order['status'] as String? ?? 'pending';
    final total = (order['totalAmount'] as num?)?.toDouble() ?? 0.0;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order Details',
                  style: GoogleFonts.cairo(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order status
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Status: ${status.toUpperCase()}',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Total: \$${total.toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Items
                  Text(
                    'Items (${items.length})',
                    style: GoogleFonts.cairo(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  ...items.map((item) {
                    final productData =
                        item['productData'] as Map<String, dynamic>? ?? {};
                    final name =
                        productData['name'] as String? ?? 'Unknown Product';
                    final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                    final quantity = item['quantity'] as int? ?? 1;
                    final totalPrice =
                        (item['totalPrice'] as num?)?.toDouble() ??
                        (price * quantity);

                    return Container(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[200]!),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: GoogleFonts.cairo(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Qty: $quantity × \$${price.toStringAsFixed(2)}',
                                  style: GoogleFonts.cairo(
                                    color: Colors.grey[600],
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: GoogleFonts.cairo(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
