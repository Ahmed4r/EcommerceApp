// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shop/screens/admin/orders_admin_page.dart';
// import 'package:shop/app_colors.dart';
// import 'package:shop/services/orders_service.dart';

// class OrdersPage extends StatefulWidget {
//   static const String routeName = '/orders';

//   const OrdersPage({super.key});

//   @override
//   State<OrdersPage> createState() => _OrdersPageState();
// }

// class _OrdersPageState extends State<OrdersPage> {
//   late Future<List<Map<String, dynamic>>> _future;
//   RealtimeChannel? _channel;

//   @override
//   void initState() {
//     super.initState();
//     _future = OrdersService.instance.fetchMyOrders();
//     _subscribeToRealtime();
//   }

//   void _subscribeToRealtime() {
//     final userId = Supabase.instance.client.auth.currentUser?.id;
//     if (userId == null) return;
//     _channel = Supabase.instance.client
//         .channel('orders_list_$userId')
//         .onPostgresChanges(
//           event: PostgresChangeEvent.all,
//           schema: 'public',
//           table: 'orders',
//           filter: PostgresChangeFilter(
//             type: PostgresChangeFilterType.eq,
//             column: 'user_id',
//             value: userId,
//           ),
//           callback: (_) {
//             if (!mounted) return;
//             setState(() {
//               _future = OrdersService.instance.fetchMyOrders();
//             });
//           },
//         )
//         .subscribe();
//   }

//   @override
//   void dispose() {
//     if (_channel != null) {
//       Supabase.instance.client.removeChannel(_channel!);
//     }
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBar(
//         forceMaterialTransparency: true,
//         backgroundColor: AppColors.primary,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'My Orders',
//           style: GoogleFonts.cairo(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.sp,
//             color: Colors.black,
//           ),
//         ),
//       ),
//       body: FutureBuilder<List<Map<String, dynamic>>>(
//         future: _future,
//         builder: (context, snap) {
//           if (snap.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           if (snap.hasError) {
//             return Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.r),
//                 child: Text(
//                   'Failed to load orders',
//                   style: GoogleFonts.cairo(fontSize: 16.sp),
//                 ),
//               ),
//             );
//           }
//           final orders = snap.data ?? [];
//           if (orders.isEmpty) {
//             return Center(
//               child: Padding(
//                 padding: EdgeInsets.all(16.r),
//                 child: Text(
//                   "You don't have any orders yet.",
//                   style: GoogleFonts.cairo(fontSize: 16.sp),
//                 ),
//               ),
//             );
//           }

//           return RefreshIndicator(
//             onRefresh: () async {
//               setState(() {
//                 _future = OrdersService.instance.fetchMyOrders();
//               });
//               await _future;
//             },
//             child: ListView.separated(
//               padding: EdgeInsets.all(12.r),
//               itemBuilder: (context, index) {
//                 final o = orders[index];
//                 final id = o['id'];
//                 final status = (o['status'] ?? 'pending') as String;
//                 final total = (o['total_amount'] as num?)?.toDouble() ?? 0.0;
//                 final items = (o['items'] as List?) ?? const [];
//                 return _OrderTile(
//                   orderId: id,
//                   status: status,
//                   total: total,
//                   itemCount: items.length,
//                   items: items,
//                 );
//               },
//               separatorBuilder: (_, __) => SizedBox(height: 8.h),
//               itemCount: orders.length,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class _OrderTile extends StatelessWidget {
//   final dynamic orderId;
//   final String status;
//   final double total;
//   final int itemCount;
//   final List<dynamic> items;
//   const _OrderTile({
//     required this.orderId,
//     required this.status,
//     required this.total,
//     required this.itemCount,
//     required this.items,
//   });

//   Color _colorFor(String s) {
//     switch (s) {
//       case 'confirmed':
//         return Colors.green;
//       case 'pending':
//         return Colors.orange;
//       case 'shipped':
//         return Colors.blue;
//       case 'delivered':
//         return Colors.teal;
//       case 'cancelled':
//         return Colors.red;
//       default:
//         return Colors.blueGrey;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final c = _colorFor(status);
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14.r),
//         boxShadow: [
//           BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8.r),
//         ],
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         title: Text(
//           'Order #$orderId',
//           style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
//         ),
//         subtitle: Padding(
//           padding: EdgeInsets.only(top: 4.h),
//           child: Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                 decoration: BoxDecoration(
//                   color: c.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(20.r),
//                 ),
//                 child: Text(
//                   status,
//                   style: GoogleFonts.cairo(
//                     color: c,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ),
//               SizedBox(width: 8.w),
//               Text(
//                 '$itemCount items',
//                 style: GoogleFonts.cairo(color: Colors.grey[700]),
//               ),
//             ],
//           ),
//         ),
//         trailing: Column(
//           children: [
//             Text(
//               '\$${total.toStringAsFixed(2)}',
//               style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
//             ),
//             SizedBox(height: 4.h),
//             Text(
//               'Details',
//               style: GoogleFonts.cairo(
//                 color: Colors.blueAccent,
//                 fontSize: 12.sp,
//               ),
//             ),
//           ],
//         ),
//         onTap: () {
//           Navigator.pushNamed(
//             context,
//             OrderDetailsPage.routeName,
//             arguments: {
//               'id': orderId,
//               'items': items,
//               'total_amount': total,
//               'status': status,
//             },
//           );
//         },
//       ),
//     );
//   }
// }
