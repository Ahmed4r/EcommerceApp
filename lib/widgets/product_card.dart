import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redacted/redacted.dart';

import 'package:shop/model/product_model.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/homepage/product_details.dart';

class ProductItemCard extends StatefulWidget {
  final Product product;

  const ProductItemCard({super.key, required this.product});

  @override
  _ProductItemCardState createState() => _ProductItemCardState();
}

class _ProductItemCardState extends State<ProductItemCard>
    with SingleTickerProviderStateMixin {
  final CartManager _cartManager = CartManager();
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isAddingToCart = false;
  // Only rebuild the small cart badge when quantity changes for this product
  late final ValueNotifier<int> _quantityNotifier;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _quantityNotifier = ValueNotifier<int>(_getQuantityFor(widget.product.id));
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    _animationController.dispose();
    _quantityNotifier.dispose();
    super.dispose();
  }

  void _addToCart() async {
    HapticFeedback.lightImpact();
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    // Add animation
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Add to cart
    _cartManager.addToCart(widget.product);
    log('Product ${widget.product.name} added to cart');

    // Show success message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.product.name} added to cart!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.black87,
        ),
      );
    }

    // Reset loading state
    await Future.delayed(Duration(milliseconds: 300));
    if (mounted) {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  // Update only the notifier on cart changes, not the whole card
  void _onCartChanged() {
    final newQty = _getQuantityFor(widget.product.id);
    if (_quantityNotifier.value != newQty) {
      _quantityNotifier.value = newQty;
    }
  }

  int _getQuantityFor(String productId) {
    final cartItem = _cartManager.cartItems.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItem(product: widget.product, quantity: 0),
    );
    return cartItem.quantity;
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Add validation for required product fields
    if (widget.product.id.isEmpty || widget.product.name.isEmpty) {
      return Container(
        width: 150.w,
        height: 200.h,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20.r)),
        child: Center(
          child: Text(
            'Product data incomplete',
            style: GoogleFonts.cairo(fontSize: 12.sp, color: Colors.grey[600]),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: widget.product,
              heroTag: "product_${widget.product.id}",
            ),
          ),
        );
      },
      child: Container(
        width: 150.w,
        height: 200.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              widget.product.image.isNotEmpty
                  ? widget.product.image
                  : 'https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg',
            ),
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.02),
              BlendMode.darken,
            ),
            onError: (error, stackTrace) {
              // Handle image loading error silently
            },
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(10.0).r,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top Row: Name + Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.product.name,
                      style: GoogleFonts.notoSansRejang(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 12.sp,
                        shadows: [
                          Shadow(
                            color: isDarkMode
                                ? Colors.black.withOpacity(1)
                                : Colors.black.withOpacity(0.1),
                            offset: Offset(0, 1),
                            blurRadius: 2,
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.r, sigmaY: 10.r),
                      child: Container(
                        width: 60.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.2)
                              : Colors.black.withOpacity(0.02),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: isDarkMode
                                ? Colors.white.withOpacity(0.3)
                                : Colors.black.withOpacity(0.02),
                            width: 1.5.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.02),
                              blurRadius: 10.r,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Icon(
                              Icons.star_border_rounded,
                              color: isDarkMode ? Colors.white : Colors.black,
                              size: 18.sp,
                            ),
                            Text(
                              widget.product.rate.toString(),
                              style: GoogleFonts.cairo(
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Bottom Row: Price + Add to Cart
              ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 140.w,
                    height: 40.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDarkMode
                            ? Colors.white.withOpacity(0.3)
                            : Colors.black.withOpacity(0.1),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10.r,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          "\$ ${widget.product.price.toString()}",
                          style: GoogleFonts.cairo(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        GestureDetector(
                          onTap: _addToCart,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 15.r,
                                    child: _isAddingToCart
                                        ? SizedBox(
                                            width: 12.w,
                                            height: 12.h,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                            ),
                                          )
                                        : ValueListenableBuilder<int>(
                                            valueListenable: _quantityNotifier,
                                            builder: (context, qty, _) {
                                              return Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  FaIcon(
                                                    FontAwesomeIcons
                                                        .bagShopping,
                                                    color: Colors.white,
                                                    size: 16.sp,
                                                  ),
                                                  if (qty > 0)
                                                    Positioned(
                                                      top: -2.h,
                                                      right: -2.w,
                                                      child: Container(
                                                        width: 10.w,
                                                        height: 10.h,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                        child: Center(
                                                          child: Text(
                                                            qty.toString(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 8.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              );
                                            },
                                          ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ).redacted(
      context: context,
      redact: true,
      configuration: RedactedConfiguration(
        animationDuration: const Duration(milliseconds: 800), //default
      ),
    );
  }
}

// Function version (if you prefer to keep it as a function)
Widget buildItemCard(BuildContext context, Product obj) {
  return ProductItemCard(product: obj);
}
