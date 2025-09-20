import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/screens/cart/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  static const String routeName = '/cart';

  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

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

    // Listen to cart changes
    CartManager().addListener(_onCartChanged);

    // Load cart from Firebase for current user (if logged in)
    // Fire-and-forget; UI will update via listeners when done
    CartManager().loadCartFromFirebase();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    CartManager().removeListener(_onCartChanged);
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = CartManager().cartItems;
    final totalPrice = CartManager().totalPrice;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: _buildAppBar(context),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(cartItems, totalPrice),
      bottomNavigationBar: cartItems.isNotEmpty
          ? _buildCheckoutButton(totalPrice)
          : null,
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
        'Shopping Cart',
        style: GoogleFonts.cairo(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        ),
      ),
      centerTitle: true,
      actions: [
        if (CartManager().cartItems.isNotEmpty)
          IconButton(
            onPressed: () => _showClearCartDialog(),
            icon: Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.delete_outline, color: Colors.red, size: 20.sp),
            ),
          ),
        SizedBox(width: 16.w),
      ],
    );
  }

  Widget _buildEmptyCart() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
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
                'Add some products to get started',
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 32.h),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 32.w,
                    vertical: 16.h,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25.r),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12.r,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    'Start Shopping',
                    style: GoogleFonts.cairo(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartContent(List<CartItem> cartItems, double totalPrice) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          // Cart Summary
          Padding(
            padding: EdgeInsets.all(16.r),
            child: SlideTransition(
              position: _slideAnimation,
              child: Container(
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
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${cartItems.length} Items',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Text(
                          '\$${totalPrice.toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleLarge?.color,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Icon(
                        FontAwesomeIcons.receipt,
                        color: Theme.of(context).colorScheme.primary,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Cart Items List
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: cartItems.length,
              itemBuilder: (context, index) {
                return SlideTransition(
                  position: Tween<Offset>(begin: Offset(1, 0), end: Offset.zero)
                      .animate(
                        CurvedAnimation(
                          parent: _slideController,
                          curve: Interval(
                            index * 0.1,
                            1.0,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                      ),
                  child: CartItemCard(
                    cartItem: cartItems[index],
                    onQuantityChanged: (quantity) {
                      if (quantity <= 0) {
                        CartManager().removeFromCart(
                          cartItems[index].product.id,
                        );
                      } else {
                        CartManager().updateQuantity(
                          cartItems[index].product.id,
                          quantity,
                        );
                      }
                    },
                    onRemove: () {
                      CartManager().removeFromCart(cartItems[index].product.id);
                    },
                  ),
                );
              },
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
      child: SlideTransition(
        position: Tween<Offset>(begin: Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutBack),
        ),
        child: GestureDetector(
          onTap: _handleCheckout,
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 18.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.green, Colors.greenAccent],
              ),
              borderRadius: BorderRadius.circular(25.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 12.r,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.creditCard,
                  size: 20.sp,
                  color: Colors.white,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Checkout • \$${totalPrice.toStringAsFixed(2)}',
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

  void _handleCheckout() {
    // Navigate to the new Checkout screen with address, payment, and status
    Navigator.pushNamed(context, CheckoutScreen.routeName);
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        title: Text(
          'Clear Cart',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        content: Text(
          'Are you sure you want to remove all items from your cart?',
          style: GoogleFonts.cairo(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.cairo(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              CartManager().clearCart();
              Navigator.pop(context);
            },
            child: Text('Clear', style: GoogleFonts.cairo(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// Cart Item Card Widget
class CartItemCard extends StatefulWidget {
  final CartItem cartItem;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(16.r),
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
              child: Row(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15.r),
                    child: SizedBox(
                      width: 80.w,
                      height: 80.h,
                      child: Image.network(
                        widget.cartItem.product.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Theme.of(context).colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.image_not_supported,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cartItem.product.name,
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(
                              context,
                            ).textTheme.titleMedium?.color,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.cartItem.product.category,
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          '\$${widget.cartItem.product.price.toStringAsFixed(2)}',
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Quantity Controls
                  Column(
                    children: [
                      // Remove Button
                      GestureDetector(
                        onTap: widget.onRemove,
                        child: Container(
                          padding: EdgeInsets.all(6.r),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                            size: 18.sp,
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),

                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _controller.forward().then((_) {
                                  _controller.reverse();
                                });
                                widget.onQuantityChanged(
                                  widget.cartItem.quantity + 1,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                child: Icon(
                                  Icons.add,
                                  size: 16.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 4.h,
                              ),
                              child: Text(
                                widget.cartItem.quantity.toString(),
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.color,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _controller.forward().then((_) {
                                  _controller.reverse();
                                });
                                widget.onQuantityChanged(
                                  widget.cartItem.quantity - 1,
                                );
                              },
                              child: Container(
                                padding: EdgeInsets.all(8.r),
                                child: Icon(
                                  Icons.remove,
                                  size: 16.sp,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Checkout Success Dialog
class CheckoutSuccessDialog extends StatefulWidget {
  const CheckoutSuccessDialog({super.key});

  @override
  State<CheckoutSuccessDialog> createState() => _CheckoutSuccessDialogState();
}

class _CheckoutSuccessDialogState extends State<CheckoutSuccessDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _checkController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _checkController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _checkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkController, curve: Curves.easeInOut),
    );

    _startAnimations();
  }

  void _startAnimations() async {
    await _scaleController.forward();
    await _checkController.forward();

    await Future.delayed(Duration(seconds: 2));

    // Clear cart and close dialog
    CartManager().clearCart();
    Navigator.of(context).pop();
    Navigator.of(context).pop(); // Go back to home
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _checkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ScaleTransition(
        scale: _scaleAnimation,
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
              AnimatedBuilder(
                animation: _checkAnimation,
                builder: (context, child) {
                  return Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: Transform.scale(
                      scale: _checkAnimation.value,
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 40.sp,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              Text(
                'Order Successful!',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Your order has been placed successfully',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CartManager {
  static final CartManager _instance = CartManager._internal();
  factory CartManager() => _instance;
  CartManager._internal();

  final List<CartItem> _cartItems = [];
  final List<VoidCallback> _listeners = [];
  bool _isLoading = false;

  // Firebase services
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<CartItem> get cartItems => _cartItems;
  int get itemCount => _cartItems.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => _cartItems.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }

  void addToCart(Product product) {
    int existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity++;
    } else {
      _cartItems.add(CartItem(product: product, quantity: 1));
    }
    _notifyListeners();
    _saveToLocal();

    // Sync to Firebase (optimistic)
    _upsertRemote(
      product.id,
      _cartItems.firstWhere((i) => i.product.id == product.id).quantity,
    );
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    _notifyListeners();
    _saveToLocal();

    // Remote delete
    _deleteRemote(productId);
  }

  void updateQuantity(String productId, int quantity) {
    int index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _cartItems.removeAt(index);
      } else {
        _cartItems[index].quantity = quantity;
      }
      _notifyListeners();
      _saveToLocal();

      // Sync remotely
      if (quantity <= 0) {
        _deleteRemote(productId);
      } else {
        _upsertRemote(productId, quantity);
      }
    }
  }

  void clearCart() {
    _cartItems.clear();
    _notifyListeners();
    _saveToLocal();

    // Remote clear for current user
    _clearRemote();
  }

  // Load cart from Firebase
  Future<void> loadCartFromFirebase() async {
    if (_isLoading) return;
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      // User not logged in, load from local storage
      await _loadFromLocal();
      return;
    }

    _isLoading = true;
    try {
      final querySnapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      final List<CartItem> fetched = [];
      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final productData = data['productData'] as Map<String, dynamic>?;
          if (productData == null) continue;
          final qty = (data['quantity'] as int?) ?? 1;
          fetched.add(
            CartItem(product: Product.fromJson(productData), quantity: qty),
          );
        } catch (e) {
          print('Error parsing cart item: $e');
        }
      }
      _cartItems
        ..clear()
        ..addAll(fetched);
      _notifyListeners();
      _saveToLocal(); // Save to local storage for offline access
    } catch (e) {
      print('Error loading cart from Firebase: $e');
      // Fallback to local storage
      await _loadFromLocal();
    } finally {
      _isLoading = false;
    }
  }

  // Local storage methods
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = _cartItems
          .map(
            (item) => {
              'product': item.product.toJson(),
              'quantity': item.quantity,
            },
          )
          .toList();
      await prefs.setString('cart', jsonEncode(cartJson));
    } catch (e) {
      print('Error saving cart to local storage: $e');
    }
  }

  Future<void> _loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');
      if (cartString != null) {
        final cartJson = jsonDecode(cartString) as List<dynamic>;
        final cartItems = cartJson.map((item) {
          final itemMap = item as Map<String, dynamic>;
          return CartItem(
            product: Product.fromJson(itemMap['product']),
            quantity: itemMap['quantity'] as int,
          );
        }).toList();

        _cartItems
          ..clear()
          ..addAll(cartItems);
        _notifyListeners();
      }
    } catch (e) {
      print('Error loading cart from local storage: $e');
    }
  }

  Future<void> _upsertRemote(String productId, int quantity) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final cartItem = _cartItems.firstWhere(
        (item) => item.product.id == productId,
      );

      final docRef = _firestore.collection('cart').doc('${userId}_$productId');

      await docRef.set({
        'userId': userId,
        'productId': productId,
        'productData': cartItem.product.toJson(),
        'quantity': quantity,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error upserting cart item to Firebase: $e');
    }
  }

  Future<void> _deleteRemote(String productId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      await _firestore.collection('cart').doc('${userId}_$productId').delete();
    } catch (e) {
      print('Error deleting cart item from Firebase: $e');
    }
  }

  Future<void> _clearRemote() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      final querySnapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Error clearing cart from Firebase: $e');
    }
  }

  // Method to sync local cart to Firebase when user logs in
  Future<void> syncLocalToFirebase() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get local cart items
      final prefs = await SharedPreferences.getInstance();
      final cartString = prefs.getString('cart');
      if (cartString == null) return;

      final cartJson = jsonDecode(cartString) as List<dynamic>;
      if (cartJson.isEmpty) return;

      // Get existing cart from Firebase
      final existingSnapshot = await _firestore
          .collection('cart')
          .where('userId', isEqualTo: userId)
          .get();

      Map<String, int> existingQuantities = {};
      for (var doc in existingSnapshot.docs) {
        final data = doc.data();
        existingQuantities[data['productId']] = data['quantity'] as int;
      }

      // Batch write for better performance
      final batch = _firestore.batch();

      for (var item in cartJson) {
        final itemMap = item as Map<String, dynamic>;
        final product = Product.fromJson(itemMap['product']);
        final quantity = itemMap['quantity'] as int;

        // Merge local and remote quantities
        final existingQty = existingQuantities[product.id] ?? 0;
        final newQuantity = quantity + existingQty;

        final docRef = _firestore
            .collection('cart')
            .doc('${userId}_${product.id}');

        batch.set(docRef, {
          'userId': userId,
          'productId': product.id,
          'productData': product.toJson(),
          'quantity': newQuantity,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Clear local storage after sync
      await prefs.remove('cart');

      // Reload cart from Firebase
      await loadCartFromFirebase();
    } catch (e) {
      print('Error syncing local cart to Firebase: $e');
    }
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}
