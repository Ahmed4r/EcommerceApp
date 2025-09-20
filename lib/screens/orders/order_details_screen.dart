import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/orders_service.dart';

class OrderDetailsScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailsScreen({super.key, required this.orderId});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen>
    with TickerProviderStateMixin {
  Map<String, dynamic>? _orderDetails;
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadOrderDetails();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadOrderDetails() async {
    try {
      final details = await OrdersService.instance.getOrderDetails(
        widget.orderId,
      );
      setState(() {
        _orderDetails = details;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load order details: $e');
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
          'Order Details',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orderDetails == null
          ? _buildErrorState()
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderHeader(),
                    SizedBox(height: 24.h),
                    _buildTrackingTimeline(),
                    SizedBox(height: 24.h),
                    _buildOrderItems(),
                    SizedBox(height: 24.h),
                    _buildShippingAddress(),
                    SizedBox(height: 24.h),
                    _buildPaymentInfo(),
                    SizedBox(height: 24.h),
                    _buildOrderSummary(),
                    SizedBox(height: 100.h), // Extra space for bottom
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FaIcon(
            FontAwesomeIcons.triangleExclamation,
            size: 80.sp,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          SizedBox(height: 24.h),
          Text(
            'Order Not Found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Unable to load order details.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: _loadOrderDetails,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHeader() {
    final theme = Theme.of(context);
    final createdAt = _orderDetails!['createdAt'] as Timestamp?;
    final date = createdAt?.toDate() ?? DateTime.now();
    final formattedDate = DateFormat('MMMM dd, yyyy').format(date);
    final formattedTime = DateFormat('hh:mm a').format(date);
    final status = _orderDetails!['status'] as String? ?? 'pending';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${widget.orderId.substring(0, 8).toUpperCase()}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Placed on $formattedDate at $formattedTime',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(status),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingTimeline() {
    final theme = Theme.of(context);
    final status = _orderDetails!['status'] as String? ?? 'pending';

    final statuses = ['pending', 'processing', 'shipped', 'delivered'];
    final currentIndex = statuses.indexOf(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Tracking',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 20.h),
            Column(
              children: statuses.asMap().entries.map((entry) {
                final index = entry.key;
                final statusName = entry.value;
                final isCompleted = index <= currentIndex;
                final isActive = index == currentIndex;
                final isLast = index == statuses.length - 1;

                return _buildTimelineItem(
                  statusName,
                  isCompleted,
                  isActive,
                  isLast,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    String status,
    bool isCompleted,
    bool isActive,
    bool isLast,
  ) {
    final theme = Theme.of(context);

    Color getColor() {
      if (isCompleted) return theme.colorScheme.primary;
      return theme.colorScheme.onSurface.withOpacity(0.3);
    }

    IconData getIcon() {
      switch (status) {
        case 'pending':
          return FontAwesomeIcons.clock;
        case 'processing':
          return FontAwesomeIcons.gear;
        case 'shipped':
          return FontAwesomeIcons.truck;
        case 'delivered':
          return FontAwesomeIcons.circleCheck;
        default:
          return FontAwesomeIcons.question;
      }
    }

    String getTitle() {
      switch (status) {
        case 'pending':
          return 'Order Placed';
        case 'processing':
          return 'Order Processing';
        case 'shipped':
          return 'Order Shipped';
        case 'delivered':
          return 'Order Delivered';
        default:
          return status.toUpperCase();
      }
    }

    String getDescription() {
      switch (status) {
        case 'pending':
          return 'Your order has been placed successfully';
        case 'processing':
          return 'Your order is being prepared';
        case 'shipped':
          return 'Your order is on the way';
        case 'delivered':
          return 'Your order has been delivered';
        default:
          return '';
      }
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: getColor(),
                shape: BoxShape.circle,
                border: Border.all(color: getColor(), width: 2),
              ),
              child: Icon(
                getIcon(),
                color: isCompleted ? Colors.white : getColor(),
                size: 18.sp,
              ),
            ),
            if (!isLast)
              Container(
                width: 2.w,
                height: 40.h,
                color: getColor(),
                margin: EdgeInsets.symmetric(vertical: 8.h),
              ),
          ],
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(top: 8.h, bottom: isLast ? 0 : 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTitle(),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                ),
                if (getDescription().isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Text(
                    getDescription(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isCompleted
                          ? theme.colorScheme.onSurface.withOpacity(0.7)
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems() {
    final theme = Theme.of(context);
    final items = _orderDetails!['items'] as List<dynamic>? ?? [];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Items',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => Divider(height: 24.h),
              itemBuilder: (context, index) {
                final item = items[index];
                final productData =
                    item['productData'] as Map<String, dynamic>? ?? {};
                final quantity = item['quantity'] as int? ?? 1;
                final price = (item['price'] as num?)?.toDouble() ?? 0.0;
                final totalPrice =
                    (item['totalPrice'] as num?)?.toDouble() ?? 0.0;

                return _buildOrderItem(
                  productData,
                  quantity,
                  price,
                  totalPrice,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(
    Map<String, dynamic> product,
    int quantity,
    double price,
    double totalPrice,
  ) {
    final theme = Theme.of(context);
    final productName = product['name'] as String? ?? 'Unknown Product';
    final productImage = product['image'] as String? ?? '';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: productImage.isNotEmpty
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8.r),
                  child: Image.asset(
                    productImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        size: 24.sp,
                      );
                    },
                  ),
                )
              : Icon(
                  Icons.image_not_supported,
                  color: theme.colorScheme.onSurface.withOpacity(0.5),
                  size: 24.sp,
                ),
        ),

        SizedBox(width: 12.w),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                productName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4.h),
              Text(
                'Quantity: $quantity',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Unit Price: \$${price.toStringAsFixed(2)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Total Price
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '\$${totalPrice.toStringAsFixed(2)}',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShippingAddress() {
    final theme = Theme.of(context);
    final address = _orderDetails!['address'] as Map<String, dynamic>?;

    if (address == null) return const SizedBox.shrink();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.locationDot,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Shipping Address',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              address['label'] as String? ?? 'Address',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              address['address'] as String? ?? 'No address provided',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo() {
    final theme = Theme.of(context);
    final paymentMethod = _orderDetails!['paymentMethod'] as String? ?? 'N/A';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.creditCard,
                  color: theme.colorScheme.primary,
                  size: 20.sp,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Payment Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Payment Method',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                Text(
                  paymentMethod,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    final theme = Theme.of(context);
    final totalAmount =
        (_orderDetails!['totalAmount'] as num?)?.toDouble() ?? 0.0;
    final items = _orderDetails!['items'] as List<dynamic>? ?? [];

    double subtotal = 0.0;
    for (var item in items) {
      subtotal += ((item['totalPrice'] as num?)?.toDouble() ?? 0.0);
    }

    final shipping = 5.0; // Example shipping cost
    final tax = subtotal * 0.1; // Example 10% tax

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16.h),
            _buildSummaryRow('Subtotal', subtotal),
            _buildSummaryRow('Shipping', shipping),
            _buildSummaryRow('Tax', tax),
            Divider(height: 24.h),
            _buildSummaryRow('Total', totalAmount, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface,
            ),
          ),
        ],
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
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(getStatusIcon(), size: 14.sp, color: statusColor),
          SizedBox(width: 8.w),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }
}
