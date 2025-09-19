// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:shop/app_colors.dart';
// import 'package:shop/model/address_model.dart';
// import 'package:shop/screens/location/address_details_Screen.dart';
// import 'package:shop/screens/cart/cart_screen.dart';
// import 'package:shop/services/orders_service.dart';

// class CheckoutScreen extends StatefulWidget {
//   static const String routeName = '/checkout';

//   const CheckoutScreen({super.key});

//   @override
//   State<CheckoutScreen> createState() => _CheckoutScreenState();
// }

// class _CheckoutScreenState extends State<CheckoutScreen> {
//   int _currentStep = 0; // 0: Address, 1: Payment, 2: Review

//   List<AddressModel> _addresses = [];
//   AddressModel? _selectedAddress;

//   String _paymentMethod = 'cod'; // 'cod' | 'saved_card' | 'new_card'
//   final _nameController = TextEditingController();
//   final _cardController = TextEditingController();
//   final _expiryController = TextEditingController();
//   final _cvvController = TextEditingController();

//   bool _placing = false;
//   dynamic _orderId; // Supabase order id
//   String _orderStatus = 'pending';

//   @override
//   void initState() {
//     super.initState();
//     _loadAddresses();
//     // keep in sync with cart changes
//     CartManager().addListener(_onCartChanged);
//   }

//   void _onCartChanged() {
//     if (!mounted) return;
//     setState(() {});
//   }

//   Future<void> _loadAddresses() async {
//     final prefs = await SharedPreferences.getInstance();
//     final list = prefs.getStringList('addresses') ?? [];
//     final parsed = list
//         .map(
//           (e) => AddressModel.fromJson(
//             Map<String, dynamic>.from(jsonDecode(e) as Map),
//           ),
//         )
//         .toList();
//     setState(() {
//       _addresses = parsed;
//       if (_addresses.isNotEmpty) {
//         _selectedAddress = _addresses.first;
//       }
//     });
//   }

//   bool get _canPlaceOrder {
//     // Require a selected address, valid payment input (if new card),
//     // and at least one item in the cart
//     if (CartManager().cartItems.isEmpty) return false;
//     if (_selectedAddress == null) return false;
//     if (_paymentMethod == 'new_card') {
//       return _nameController.text.trim().isNotEmpty &&
//           _cardController.text.replaceAll(' ', '').length >= 12 &&
//           _expiryController.text.trim().isNotEmpty &&
//           _cvvController.text.trim().length >= 3;
//     }
//     return true;
//   }

//   @override
//   void dispose() {
//     CartManager().removeListener(_onCartChanged);
//     _nameController.dispose();
//     _cardController.dispose();
//     _expiryController.dispose();
//     _cvvController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cart = CartManager();
//     final total = cart.totalPrice;

//     return Scaffold(
//       backgroundColor: AppColors.primary,
//       appBar: AppBar(
//         backgroundColor: AppColors.primary,
//         title: Text(
//           'Checkout',
//           style: GoogleFonts.cairo(
//             fontWeight: FontWeight.bold,
//             fontSize: 18.sp,
//             color: Colors.black,
//           ),
//         ),
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.black, size: 18.sp),
//           onPressed: () => Navigator.pop(context),
//         ),
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildStepper(),
//           if (_orderId != null)
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//               child: _OrderStatusBanner(
//                 status: _orderStatus,
//                 orderId: _orderId,
//               ),
//             ),
//           Expanded(
//             child: ListView(
//               padding: EdgeInsets.all(16.r),
//               children: [
//                 _buildAddressSection(),
//                 SizedBox(height: 16.h),
//                 _buildPaymentSection(),
//                 SizedBox(height: 16.h),
//                 _buildReviewSection(total),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: EdgeInsets.all(16.r),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8.r),
//           ],
//         ),
//         child: SafeArea(
//           child: Row(
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Total',
//                       style: GoogleFonts.cairo(
//                         color: Colors.grey[600],
//                         fontSize: 12.sp,
//                       ),
//                     ),
//                     Text(
//                       '\$${total.toStringAsFixed(2)}',
//                       style: GoogleFonts.cairo(
//                         fontWeight: FontWeight.w700,
//                         fontSize: 18.sp,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(width: 12.w),
//               SizedBox(
//                 width: 180.w,
//                 height: 50.h,
//                 child: ElevatedButton(
//                   onPressed: _placing || !_canPlaceOrder ? null : _placeOrder,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(14.r),
//                     ),
//                   ),
//                   child: _placing
//                       ? SizedBox(
//                           width: 20.r,
//                           height: 20.r,
//                           child: const CircularProgressIndicator(
//                             color: Colors.white,
//                             strokeWidth: 2,
//                           ),
//                         )
//                       : Text(
//                           'Place Order',
//                           style: GoogleFonts.cairo(
//                             color: Colors.white,
//                             fontWeight: FontWeight.w700,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildStepper() {
//     final steps = [
//       _StepData('Address', Icons.location_on),
//       _StepData('Payment', Icons.credit_card),
//       _StepData('Review', Icons.receipt_long),
//     ];
//     return Container(
//       color: AppColors.primary,
//       padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
//       child: Row(
//         children: List.generate(steps.length * 2 - 1, (i) {
//           if (i.isOdd) {
//             return Expanded(
//               child: Container(
//                 height: 2,
//                 color: i ~/ 2 < _currentStep ? Colors.green : Colors.grey[300],
//               ),
//             );
//           }
//           final idx = i ~/ 2;
//           final active = idx <= _currentStep;
//           return Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8.r),
//                 decoration: BoxDecoration(
//                   color: active ? Colors.green : Colors.grey[300],
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(steps[idx].icon, size: 16.sp, color: Colors.white),
//               ),
//               SizedBox(width: 6.w),
//               Text(
//                 steps[idx].title,
//                 style: GoogleFonts.cairo(
//                   fontSize: 12.sp,
//                   fontWeight: active ? FontWeight.w700 : FontWeight.w500,
//                   color: Colors.black,
//                 ),
//               ),
//               SizedBox(width: 8.w),
//             ],
//           );
//         }),
//       ),
//     );
//   }

//   Widget _buildAddressSection() {
//     return _SectionCard(
//       title: 'Delivery Address',
//       trailing: TextButton(
//         onPressed: _openManageAddresses,
//         child: Text('Manage', style: GoogleFonts.cairo()),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (_selectedAddress == null)
//             _EmptyTile(
//               icon: Icons.location_on,
//               title: 'No address selected',
//               subtitle: 'Choose a saved address or add a new one',
//               cta: 'Select Address',
//               onTap: _pickAddress,
//             )
//           else
//             ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: CircleAvatar(
//                 backgroundColor: _selectedAddress!.iconColor ?? Colors.blue,
//                 child: Icon(_selectedAddress!.icon, color: Colors.white),
//               ),
//               title: Text(
//                 _selectedAddress!.label ?? 'Address',
//                 style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
//               ),
//               subtitle: Text(
//                 _selectedAddress!.address ?? '',
//                 style: GoogleFonts.cairo(
//                   fontSize: 13.sp,
//                   color: Colors.grey[700],
//                 ),
//               ),
//               trailing: TextButton(
//                 onPressed: _pickAddress,
//                 child: Text('Change', style: GoogleFonts.cairo()),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Future<void> _openManageAddresses() async {
//     await Navigator.push(
//       context,
//       MaterialPageRoute(builder: (_) => const AddressListScreen()),
//     );
//     await _loadAddresses();
//   }

//   Future<void> _pickAddress() async {
//     if (_addresses.isEmpty) {
//       await _openManageAddresses();
//       return;
//     }
//     final selected = await showModalBottomSheet<AddressModel>(
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (context) {
//         return SafeArea(
//           child: Padding(
//             padding: EdgeInsets.all(16.r),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Container(
//                   width: 36.w,
//                   height: 4.h,
//                   decoration: BoxDecoration(
//                     color: Colors.grey[300],
//                     borderRadius: BorderRadius.circular(2.r),
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 Text(
//                   'Select Address',
//                   style: GoogleFonts.cairo(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 16.sp,
//                   ),
//                 ),
//                 SizedBox(height: 12.h),
//                 Flexible(
//                   child: ListView.separated(
//                     shrinkWrap: true,
//                     itemCount: _addresses.length,
//                     separatorBuilder: (_, __) => Divider(height: 1),
//                     itemBuilder: (context, i) {
//                       final a = _addresses[i];
//                       return ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: a.iconColor ?? Colors.blue,
//                           child: Icon(a.icon, color: Colors.white),
//                         ),
//                         title: Text(
//                           a.label ?? 'Address',
//                           style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
//                         ),
//                         subtitle: Text(a.address ?? ''),
//                         onTap: () => Navigator.pop(context, a),
//                       );
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 SizedBox(
//                   width: double.infinity,
//                   child: OutlinedButton(
//                     onPressed: () async {
//                       await _openManageAddresses();
//                       Navigator.pop(context);
//                     },
//                     child: Text(
//                       'Add or Edit Addresses',
//                       style: GoogleFonts.cairo(),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//     if (selected != null) {
//       setState(() => _selectedAddress = selected);
//       setState(() => _currentStep = 1);
//     }
//   }

//   Widget _buildPaymentSection() {
//     return _SectionCard(
//       title: 'Payment Method',
//       child: Column(
//         children: [
//           RadioListTile<String>(
//             value: 'cod',
//             groupValue: _paymentMethod,
//             onChanged: (v) => setState(() {
//               _paymentMethod = v!;
//               _currentStep = 2;
//             }),
//             title: Text(
//               'Cash on Delivery',
//               style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
//             ),
//             subtitle: Text('Pay in cash when your order arrives.'),
//           ),
//           RadioListTile<String>(
//             value: 'saved_card',
//             groupValue: _paymentMethod,
//             onChanged: (v) => setState(() {
//               _paymentMethod = v!;
//               _currentStep = 2;
//             }),
//             title: Text(
//               'Visa •••• 4242',
//               style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
//             ),
//             subtitle: Text('Use your saved card.'),
//           ),
//           RadioListTile<String>(
//             value: 'new_card',
//             groupValue: _paymentMethod,
//             onChanged: (v) => setState(() {
//               _paymentMethod = v!;
//               _currentStep = 1;
//             }),
//             title: Text(
//               'New Card',
//               style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
//             ),
//             subtitle: Text('Pay with a different card.'),
//           ),
//           if (_paymentMethod == 'new_card')
//             Padding(
//               padding: EdgeInsets.symmetric(horizontal: 8.w),
//               child: Column(
//                 children: [
//                   SizedBox(height: 8.h),
//                   _TextField(
//                     controller: _nameController,
//                     label: 'Cardholder Name',
//                     keyboardType: TextInputType.name,
//                   ),
//                   SizedBox(height: 8.h),
//                   _TextField(
//                     controller: _cardController,
//                     label: 'Card Number',
//                     hint: '1234 5678 9012 3456',
//                     keyboardType: TextInputType.number,
//                   ),
//                   SizedBox(height: 8.h),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _TextField(
//                           controller: _expiryController,
//                           label: 'Expiry',
//                           hint: 'MM/YY',
//                           keyboardType: TextInputType.datetime,
//                         ),
//                       ),
//                       SizedBox(width: 8.w),
//                       Expanded(
//                         child: _TextField(
//                           controller: _cvvController,
//                           label: 'CVV',
//                           keyboardType: TextInputType.number,
//                           obscure: true,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildReviewSection(double total) {
//     final items = CartManager().cartItems;
//     return _SectionCard(
//       title: 'Order Summary',
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Items (${items.length})',
//                 style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
//               ),
//               Text(
//                 '\$${total.toStringAsFixed(2)}',
//                 style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
//               ),
//             ],
//           ),
//           SizedBox(height: 8.h),
//           Divider(height: 1),
//           SizedBox(height: 8.h),
//           Wrap(
//             spacing: 8.w,
//             runSpacing: 8.h,
//             children: items.take(5).map((e) {
//               return Chip(
//                 label: Text(
//                   '${e.product.name} x${e.quantity}',
//                   overflow: TextOverflow.ellipsis,
//                 ),
//               );
//             }).toList(),
//           ),
//           if (items.length > 5)
//             Padding(
//               padding: EdgeInsets.only(top: 8.h),
//               child: Text(
//                 '+ ${items.length - 5} more items',
//                 style: GoogleFonts.cairo(color: Colors.grey[600]),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

// //   Future<void> _placeOrder() async {
// //     setState(() => _placing = true);
// //     try {
// //       // Create order in Supabase
// //       final id = await OrdersService.instance.createOrder(
// //         address: _selectedAddress,
// //         paymentMethod: _paymentMethod,
// //         total: CartManager().totalPrice,
// //         items: CartManager().cartItems,
// //       );
// //       setState(() {
// //         _orderId = id;
// //         _orderStatus = 'pending';
// //       });

// //       // Immediately clear the cart to avoid duplicate orders
// //       // (remote cart is also cleared inside CartManager)
// //       CartManager().clearCart();

// //       // Listen for status updates
// //       OrdersService.instance.streamOrderStatus(id).listen((status) {
// //         if (!mounted) return;
// //         setState(() => _orderStatus = status);
// //         if (status == 'confirmed') {
// //           // show success
// //           unawaited(
// //             showDialog(
// //               context: context,
// //               barrierDismissible: false,
// //               builder: (_) => const CheckoutSuccessDialog(),
// //             ),
// //           );
// //         }
// //       });

// //       setState(() => _currentStep = 2);
// //     } finally {
// //       if (mounted) setState(() => _placing = false);
// //     }
// //   }
// // }

// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//   final Widget? trailing;
//   const _SectionCard({required this.title, required this.child, this.trailing});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.r),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10.r,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   title,
//                   style: GoogleFonts.cairo(
//                     fontSize: 16.sp,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               if (trailing != null) trailing!,
//             ],
//           ),
//           SizedBox(height: 12.h),
//           child,
//         ],
//       ),
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final TextEditingController controller;
//   final String label;
//   final String? hint;
//   final bool obscure;
//   final TextInputType? keyboardType;
//   const _TextField({
//     required this.controller,
//     required this.label,
//     this.hint,
//     this.obscure = false,
//     this.keyboardType,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return TextField(
//       controller: controller,
//       obscureText: obscure,
//       keyboardType: keyboardType,
//       decoration: InputDecoration(
//         labelText: label,
//         hintText: hint,
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
//         isDense: true,
//         contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//       ),
//     );
//   }
// }

// class _EmptyTile extends StatelessWidget {
//   final IconData icon;
//   final String title;
//   final String subtitle;
//   final String cta;
//   final VoidCallback onTap;
//   const _EmptyTile({
//     required this.icon,
//     required this.title,
//     required this.subtitle,
//     required this.cta,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               padding: EdgeInsets.all(10.r),
//               decoration: BoxDecoration(
//                 color: Colors.grey[200],
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(icon, color: Colors.black54),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     title,
//                     style: GoogleFonts.cairo(fontWeight: FontWeight.w700),
//                   ),
//                   SizedBox(height: 4.h),
//                   Text(
//                     subtitle,
//                     style: GoogleFonts.cairo(
//                       color: Colors.grey[700],
//                       fontSize: 13.sp,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         SizedBox(height: 12.h),
//         Align(
//           alignment: Alignment.centerLeft,
//           child: OutlinedButton(
//             onPressed: onTap,
//             child: Text(cta, style: GoogleFonts.cairo()),
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _StepData {
//   final String title;
//   final IconData icon;
//   _StepData(this.title, this.icon);
// }

// class _OrderStatusBanner extends StatelessWidget {
//   final String status;
//   final dynamic orderId;
//   const _OrderStatusBanner({required this.status, required this.orderId});

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
//       padding: EdgeInsets.all(12.r),
//       decoration: BoxDecoration(
//         color: c.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(12.r),
//         border: Border.all(color: c.withOpacity(0.4)),
//       ),
//       child: Row(
//         children: [
//           Icon(Icons.info, color: c),
//           SizedBox(width: 8.w),
//           Expanded(
//             child: Text(
//               'Order #$orderId • Status: $status',
//               style: GoogleFonts.cairo(color: c, fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
