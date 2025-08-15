import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product.dart';
import 'package:shop/screens/cart/cart_Screen.dart';
import 'package:shop/screens/homepage/details.dart';

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

    // Listen to cart changes
    _cartManager.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cartManager.removeListener(_onCartChanged);
    _animationController.dispose();
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) {
      setState(() {});
    }
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
              Expanded(child: Text('${widget.product.name} added to cart!')),
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

  bool get _isInCart {
    return _cartManager.cartItems.any(
      (item) => item.product.id == widget.product.id,
    );
  }

  int get _quantityInCart {
    final cartItem = _cartManager.cartItems.firstWhere(
      (item) => item.product.id == widget.product.id,
      orElse: () => CartItem(product: widget.product, quantity: 0),
    );
    return cartItem.quantity;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(product: widget.product),
          ),
        );
      },
      child: Container(
        width: 150.w,
        height: 200.h,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(widget.product.image),
            fit: BoxFit.contain,
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
                        color: Color(0xff0D47A1),
                        fontWeight: FontWeight.bold,
                        fontSize: 12.sp,
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
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1.5.w,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
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
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            Text(
                              widget.product.rate.toString(),
                              style: GoogleFonts.cairo(
                                color: Colors.white,
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
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5.w,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
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
                            color: Colors.black,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
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
                                        : Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              FaIcon(
                                                FontAwesomeIcons.bagShopping,
                                                color: Colors.white,
                                                size: 16.sp,
                                              ),
                                              if (_isInCart &&
                                                  _quantityInCart > 0)
                                                Positioned(
                                                  top: -2.h,
                                                  right: -2.w,
                                                  child: Container(
                                                    width: 10.w,
                                                    height: 10.h,
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        _quantityInCart
                                                            .toString(),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 8.sp,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
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
    );
  }
}

// Function version (if you prefer to keep it as a function)
Widget buildItemCard(BuildContext context, Product obj) {
  return ProductItemCard(product: obj);
}
