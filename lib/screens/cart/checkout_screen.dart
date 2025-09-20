import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:shop/model/address_model.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/services/orders_service.dart';

class CheckoutScreen extends StatefulWidget {
  static const String routeName = '/checkout';

  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with TickerProviderStateMixin {
  String _paymentMethod = 'cod'; // 'cod' | 'card' | 'apple_pay' | 'google_pay'
  bool _placing = false;
  int _currentStep = 0;

  // Animation Controllers
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  // Payment form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Demo addresses
  final List<AddressModel> _addresses = [
    AddressModel(
      label: 'Home',
      address:
          '123 Main Street, Downtown\nCity 12345, State\nPhone: +1 234 567 8900',
      iconName: 'home',
      iconColor: Colors.blue,
    ),
    AddressModel(
      label: 'Work',
      address:
          '456 Business Ave, Office District\nCity 54321, State\nPhone: +1 987 654 3210',
      iconName: 'work',
      iconColor: Colors.orange,
    ),
    AddressModel(
      label: 'Other',
      address:
          '789 Custom Location, Area\nCity 67890, State\nPhone: +1 555 123 4567',
      iconName: 'location_on',
      iconColor: Colors.green,
    ),
  ];

  AddressModel? _selectedAddress;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _slideController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(begin: Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _slideController.forward();
    _fadeController.forward();

    // Set default address
    _selectedAddress = _addresses.first;

    CartManager().addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartManager().removeListener(_onCartChanged);
    _slideController.dispose();
    _fadeController.dispose();
    _nameController.dispose();
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager().cartItems;
    final totalPrice = CartManager().totalPrice;

    if (cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressStepper(),
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.r),
                  child: Column(
                    children: [
                      _buildAddressSection(),
                      SizedBox(height: 20.h),
                      _buildPaymentSection(),
                      SizedBox(height: 20.h),
                      _buildOrderSummary(cartItems, totalPrice),
                      SizedBox(height: 20.h),
                      _buildPromoCode(),
                      SizedBox(height: 100.h), // Space for bottom button
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildCheckoutButton(totalPrice),
    );
  }

  Widget _buildEmptyCart() {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(
                FontAwesomeIcons.cartShopping,
                size: 60.sp,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Your cart is empty',
              style: GoogleFonts.cairo(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add some products to checkout',
              style: GoogleFonts.cairo(
                fontSize: 16.sp,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: Icon(FontAwesomeIcons.arrowLeft),
              label: Text('Go Back to Shopping'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      forceMaterialTransparency: true,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
          ),
          child: Center(
            child: Icon(
              Icons.arrow_back_ios,
              size: 18.r,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ),
      title: Text(
        'Checkout',
        style: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildProgressStepper() {
    final steps = [
      StepInfo('Address', FontAwesomeIcons.locationDot),
      StepInfo('Payment', FontAwesomeIcons.creditCard),
      StepInfo('Review', FontAwesomeIcons.receipt),
    ];

    return Container(
      margin: EdgeInsets.all(16.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            // Progress line
            return Expanded(
              child: Container(
                height: 2.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: index ~/ 2 < _currentStep
                        ? [Colors.green, Colors.greenAccent]
                        : [
                            Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                            Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.1),
                          ],
                  ),
                  borderRadius: BorderRadius.circular(1.r),
                ),
              ),
            );
          }

          // Step indicator
          final stepIndex = index ~/ 2;
          final isActive = stepIndex <= _currentStep;
          final isCompleted = stepIndex < _currentStep;

          return Column(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  gradient: isActive
                      ? LinearGradient(
                          colors: [Colors.green, Colors.greenAccent],
                        )
                      : null,
                  color: !isActive
                      ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                      : null,
                  shape: BoxShape.circle,
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8.r,
                            offset: Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Icon(
                  isCompleted ? FontAwesomeIcons.check : steps[stepIndex].icon,
                  size: 16.sp,
                  color: isActive
                      ? Colors.white
                      : Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                steps[stepIndex].title,
                style: GoogleFonts.cairo(
                  fontSize: 12.sp,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                  color: isActive
                      ? Theme.of(context).textTheme.titleMedium?.color
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAddressSection() {
    return _EnhancedSectionCard(
      title: 'Delivery Address',
      icon: FontAwesomeIcons.locationDot,
      iconColor: Colors.blue,
      child: Column(
        children: [
          // Current selected address
          if (_selectedAddress != null)
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: _selectedAddress!.iconColor?.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _selectedAddress!.icon,
                      color: _selectedAddress!.iconColor,
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedAddress!.label ?? 'Address',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                            color: Theme.of(
                              context,
                            ).textTheme.titleMedium?.color,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          _selectedAddress!.address ?? '',
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _showAddressSelector,
                    icon: Icon(
                      FontAwesomeIcons.chevronRight,
                      size: 16.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16.h),

          // Quick address options
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _addresses.map((address) {
                final isSelected = _selectedAddress?.label == address.label;
                return GestureDetector(
                  onTap: () => setState(() {
                    _selectedAddress = address;
                    _currentStep = 1;
                  }),
                  child: Container(
                    margin: EdgeInsets.only(right: 12.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8.r,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          address.icon,
                          size: 16.sp,
                          color: isSelected ? Colors.white : address.iconColor,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          address.label ?? '',
                          style: GoogleFonts.cairo(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return _EnhancedSectionCard(
      title: 'Payment Method',
      icon: FontAwesomeIcons.creditCard,
      iconColor: Colors.green,
      child: Column(
        children: [
          // Payment options
          _PaymentOption(
            value: 'cod',
            groupValue: _paymentMethod,
            icon: FontAwesomeIcons.handHoldingDollar,
            title: 'Cash on Delivery',
            subtitle: 'Pay when your order arrives',
            iconColor: Colors.orange,
            onChanged: (value) => setState(() {
              _paymentMethod = value!;
              _currentStep = 2;
            }),
          ),

          SizedBox(height: 12.h),

          _PaymentOption(
            value: 'card',
            groupValue: _paymentMethod,
            icon: FontAwesomeIcons.creditCard,
            title: 'Credit/Debit Card',
            subtitle: 'Visa, Mastercard, Amex',
            iconColor: Colors.blue,
            onChanged: (value) => setState(() {
              _paymentMethod = value!;
              _currentStep = 1;
            }),
          ),

          SizedBox(height: 12.h),

          _PaymentOption(
            value: 'apple_pay',
            groupValue: _paymentMethod,
            icon: FontAwesomeIcons.apple,
            title: 'Apple Pay',
            subtitle: 'Touch ID or Face ID',
            iconColor: Colors.black,
            onChanged: (value) => setState(() {
              _paymentMethod = value!;
              _currentStep = 2;
            }),
          ),

          SizedBox(height: 12.h),

          _PaymentOption(
            value: 'google_pay',
            groupValue: _paymentMethod,
            icon: FontAwesomeIcons.google,
            title: 'Google Pay',
            subtitle: 'Fast and secure',
            iconColor: Colors.red,
            onChanged: (value) => setState(() {
              _paymentMethod = value!;
              _currentStep = 2;
            }),
          ),

          // Card form for credit card option
          if (_paymentMethod == 'card') ...[
            SizedBox(height: 20.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(15.r),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  _CustomTextField(
                    controller: _nameController,
                    label: 'Cardholder Name',
                    icon: FontAwesomeIcons.user,
                    keyboardType: TextInputType.name,
                  ),
                  SizedBox(height: 16.h),
                  _CustomTextField(
                    controller: _cardController,
                    label: 'Card Number',
                    icon: FontAwesomeIcons.creditCard,
                    hint: '1234 5678 9012 3456',
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: _CustomTextField(
                          controller: _expiryController,
                          label: 'Expiry',
                          icon: FontAwesomeIcons.calendar,
                          hint: 'MM/YY',
                          keyboardType: TextInputType.datetime,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: _CustomTextField(
                          controller: _cvvController,
                          label: 'CVV',
                          icon: FontAwesomeIcons.lock,
                          hint: '123',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderSummary(List<CartItem> cartItems, double totalPrice) {
    return _EnhancedSectionCard(
      title: 'Order Summary',
      icon: FontAwesomeIcons.receipt,
      iconColor: Colors.purple,
      child: Column(
        children: [
          // Summary row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${cartItems.length} Items',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.titleMedium?.color,
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Item list
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: cartItems.take(3).map((item) {
                return Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: SizedBox(
                          width: 40.w,
                          height: 40.h,
                          child: Image.network(
                            item.product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Theme.of(
                                  context,
                                ).colorScheme.surfaceVariant,
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 20.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.product.name,
                              style: GoogleFonts.cairo(
                                fontWeight: FontWeight.w600,
                                fontSize: 14.sp,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleSmall?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Qty: ${item.quantity}',
                              style: GoogleFonts.cairo(
                                fontSize: 12.sp,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                        style: GoogleFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                          color: Theme.of(context).textTheme.titleSmall?.color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          if (cartItems.length > 3) ...[
            SizedBox(height: 12.h),
            Text(
              '+ ${cartItems.length - 3} more items',
              style: GoogleFonts.cairo(
                fontSize: 14.sp,
                color: Theme.of(context).textTheme.bodySmall?.color,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Cost breakdown
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _CostRow('Subtotal', totalPrice),
                _CostRow('Delivery', 0.0),
                _CostRow('Tax', totalPrice * 0.1),
                Divider(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    Text(
                      '\$${(totalPrice * 1.1).toStringAsFixed(2)}',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoCode() {
    return _EnhancedSectionCard(
      title: 'Promo Code',
      icon: FontAwesomeIcons.tag,
      iconColor: Colors.red,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: GoogleFonts.cairo(
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 14.h,
                ),
              ),
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: () {
              // Handle promo code application
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Promo code applied!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(
              'Apply',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutButton(double totalPrice) {
    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10.r,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: GestureDetector(
          onTap: _placing ? null : _placeOrder,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _placing
                    ? [Colors.grey, Colors.grey.shade400]
                    : [Colors.green, Colors.greenAccent],
              ),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: (_placing ? Colors.grey : Colors.green).withOpacity(
                    0.3,
                  ),
                  blurRadius: 12.r,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: _placing
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20.w,
                        height: 20.h,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Processing Order...',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        FontAwesomeIcons.lock,
                        size: 18.sp,
                        color: Colors.white,
                      ),
                      SizedBox(width: 12.w),
                      Text(
                        'Place Order • \$${(totalPrice * 1.1).toStringAsFixed(2)}',
                        style: GoogleFonts.cairo(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.only(top: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),

              SizedBox(height: 20.h),

              Text(
                'Select Delivery Address',
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),

              SizedBox(height: 20.h),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    final isSelected = _selectedAddress?.label == address.label;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAddress = address;
                          _currentStep = 1;
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 16.h),
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1)
                              : Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(15.r),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(
                                    context,
                                  ).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(12.r),
                              decoration: BoxDecoration(
                                color: address.iconColor?.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                address.icon,
                                color: address.iconColor,
                                size: 20.sp,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address.label ?? 'Address',
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.titleMedium?.color,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    address.address ?? '',
                                    style: GoogleFonts.cairo(
                                      fontSize: 14.sp,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.color
                                          ?.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                FontAwesomeIcons.check,
                                color: Theme.of(context).colorScheme.primary,
                                size: 16.sp,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    setState(() => _placing = true);

    try {
      // Validate form if credit card is selected
      if (_paymentMethod == 'card') {
        if (_nameController.text.trim().isEmpty ||
            _cardController.text.trim().length < 16 ||
            _expiryController.text.trim().isEmpty ||
            _cvvController.text.trim().length < 3) {
          throw Exception('Please fill in all card details');
        }
      }

      // Create order in Firebase
      final orderId = await OrdersService.instance.createOrder(
        address: _selectedAddress!,
        paymentMethod: _paymentMethod,
        total: CartManager().totalPrice * 1.1, // Including tax
        items: CartManager().cartItems,
      );

      // Clear the cart
      CartManager().clearCart();

      // Show success dialog
      if (mounted) {
        _showOrderSuccessDialog(orderId);
      }
    } catch (e) {
      // Show error dialog
      if (mounted) {
        _showErrorDialog(e.toString());
      }
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  void _showOrderSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(32.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(30.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.2),
                blurRadius: 20.r,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80.w,
                height: 80.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green, Colors.greenAccent],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.check,
                  color: Colors.white,
                  size: 40.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Order Placed Successfully!',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                'Order ID: ${orderId.substring(0, 8)}...',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'Your order has been placed successfully. You can track your order in the Orders section.',
                style: GoogleFonts.cairo(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close checkout screen
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Continue Shopping',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close dialog
                        Navigator.of(context).pop(); // Close checkout screen
                        // Navigate to orders screen (implement this)
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: 14.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        'Track Order',
                        style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Row(
          children: [
            Icon(
              FontAwesomeIcons.triangleExclamation,
              color: Colors.red,
              size: 24.sp,
            ),
            SizedBox(width: 12.w),
            Text(
              'Order Failed',
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ),
          ],
        ),
        content: Text(
          'Failed to place order: $error',
          style: GoogleFonts.cairo(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.cairo(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper Classes
class StepInfo {
  final String title;
  final IconData icon;

  StepInfo(this.title, this.icon);
}

class _EnhancedSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _EnhancedSectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withOpacity(0.8),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
            ),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 10.r,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 20.sp, color: iconColor),
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final String value;
  final String groupValue;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final ValueChanged<String?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.cairo(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                      color: Theme.of(context).textTheme.titleMedium?.color,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: GoogleFonts.cairo(
                      fontSize: 12.sp,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscureText;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: GoogleFonts.cairo(
        color: Theme.of(context).textTheme.bodyMedium?.color,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        labelStyle: GoogleFonts.cairo(
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        hintStyle: GoogleFonts.cairo(
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }
}

class _CostRow extends StatelessWidget {
  final String label;
  final double amount;

  const _CostRow(this.label, this.amount);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            amount == 0.0 ? 'Free' : '\$${amount.toStringAsFixed(2)}',
            style: GoogleFonts.cairo(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: amount == 0.0
                  ? Colors.green
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
