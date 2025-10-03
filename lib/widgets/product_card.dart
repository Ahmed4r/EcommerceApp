import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/homepage/product_details.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

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
  bool _isInWishlist = false;
  bool _isTogglingWishlist = false;
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

    // Load wishlist state after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWishlistState();
    });
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

  // Load wishlist state from WishlistCubit
  void _loadWishlistState() {
    try {
      final wishlistCubit = context.read<WishlistCubit>();
      setState(() {
        _isInWishlist = wishlistCubit.isFavorite(widget.product);
      });
    } catch (e) {
      log('Error loading wishlist state: $e');
      setState(() {
        _isInWishlist = false;
      });
    }
  }

  // Toggle wishlist state using WishlistCubit
  Future<void> _toggleWishlist() async {
    if (_isTogglingWishlist) return;

    setState(() {
      _isTogglingWishlist = true;
    });

    try {
      HapticFeedback.lightImpact();

      final wishlistCubit = context.read<WishlistCubit>();

      // Use WishlistCubit to toggle favorite
      await wishlistCubit.toggleFavorite(widget.product);

      // Update local state to match cubit state
      setState(() {
        _isInWishlist = wishlistCubit.isFavorite(widget.product);
      });

      if (_isInWishlist) {
        // Animate the heart for adding
        _animationController.forward().then((_) {
          _animationController.reverse();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Added to wishlist',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.black87,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.heart_broken, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Removed from wishlist',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: Duration(seconds: 1),
              backgroundColor: Colors.black87,
            ),
          );
        }
      }
    } catch (e) {
      log('Error toggling wishlist: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating wishlist'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTogglingWishlist = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Add validation for required product fields
    if (widget.product.id.isEmpty || widget.product.name.isEmpty) {
      return Container(
        width: 180.w,
        height: 250.h,
        margin: EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Text(
            'Product data incomplete',
            style: GoogleFonts.sen(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
      );
    }

    // Calculate discount
    final hasDiscount =
        widget.product.oldPrice != null &&
        widget.product.oldPrice! > widget.product.price;
    final discountPercent = hasDiscount
        ? ((widget.product.oldPrice! - widget.product.price) /
                  widget.product.oldPrice! *
                  100)
              .round()
        : 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
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
        constraints: BoxConstraints(
          minWidth: 160.w,
          maxWidth: 200.w,
          minHeight: 220.h,
          maxHeight: 280.h,
        ),
        margin: EdgeInsets.all(6.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: 15,
              offset: Offset(0, 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section with Discount Badge
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Product Image
                    Container(
                      width: double.infinity,
                      margin: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        color: Colors.grey[100],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: Hero(
                          tag: "product_${widget.product.id}",
                          child: Image.network(
                            widget.product.image.isNotEmpty
                                ? widget.product.image
                                : 'https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.image_not_supported_outlined,
                                  size: 40.sp,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),

                    // Discount Badge
                    if (hasDiscount)
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '-$discountPercent%',
                            style: GoogleFonts.sen(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Interactive Wishlist Button
                    Positioned(
                      top: 8.h,
                      left: 8.w,
                      child: BlocListener<WishlistCubit, WishlistState>(
                        listener: (context, state) {
                          // Update local state when wishlist changes from other parts of the app
                          final newState = context
                              .read<WishlistCubit>()
                              .isFavorite(widget.product);
                          if (newState != _isInWishlist && mounted) {
                            setState(() {
                              _isInWishlist = newState;
                            });
                          }
                        },
                        child: GestureDetector(
                          onTap: _toggleWishlist,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _isInWishlist
                                    ? _scaleAnimation.value
                                    : 1.0,
                                child: Container(
                                  width: 32.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                    color: _isInWishlist
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.white.withOpacity(0.9),
                                    shape: BoxShape.circle,
                                    border: _isInWishlist
                                        ? Border.all(
                                            color: Colors.red.withOpacity(0.3),
                                            width: 1,
                                          )
                                        : null,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: _isTogglingWishlist
                                      ? SizedBox(
                                          width: 12.w,
                                          height: 12.h,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                            color: Colors.red,
                                          ),
                                        )
                                      : Icon(
                                          _isInWishlist
                                              ? Icons.favorite_rounded
                                              : Icons.favorite_border_rounded,
                                          size: 18,
                                          color: _isInWishlist
                                              ? Colors.red
                                              : Colors.grey[600],
                                        ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Product Info Section - Optimized layout
              Padding(
                padding: EdgeInsets.fromLTRB(
                  8.0,
                  0,
                  8.0,
                  1.6,
                ), // Further reduced bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Name and Rating - Compact layout
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.product.name,
                          style: GoogleFonts.sen(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.white
                                : Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h), // Minimal spacing
                        Text(
                          widget.product.brand,
                          style: GoogleFonts.sen(
                            fontSize: 9.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        // Enhanced Rating Display
                        Container(
                          constraints: BoxConstraints(
                            maxWidth: double.infinity,
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.amber.withOpacity(0.3),
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 14.r,
                                color: Colors.amber[700],
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                widget.product.rate.toStringAsFixed(1),
                                style: GoogleFonts.sen(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.amber[800],
                                ),
                              ),
                              SizedBox(width: 3.w),
                              Text(
                                '(${widget.product.reviewsCount})',
                                style: GoogleFonts.sen(
                                  fontSize: 9.sp,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),            
                    SizedBox(height: 4.h),
                    // Price and Cart Section - Compact layout
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment:
                          CrossAxisAlignment.center, // Changed to center
                      children: [
                        // Price Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '\$${widget.product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.sen(
                                    fontSize: 14.sp, // Slightly reduced
                                    fontWeight: FontWeight.bold,
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                              if (hasDiscount)
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '\$${widget.product.oldPrice!.toStringAsFixed(2)}',
                                    style: GoogleFonts.sen(
                                      fontSize: 10.sp, // Reduced
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),          
                        SizedBox(width: 6.w), // Reduced spacing
                        // Add to Cart Button - Smaller to fit better
                        GestureDetector(
                          onTap: _addToCart,
                          child: AnimatedBuilder(
                            animation: _scaleAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Container(
                                  width: 38.w, // Reduced size
                                  height: 38.h,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Theme.of(context).primaryColor,
                                        Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      12.r,
                                    ), // Reduced
                                    boxShadow: [
                                      BoxShadow(
                                        color: Theme.of(context).primaryColor
                                            .withOpacity(
                                              0.2,
                                            ), // Reduced shadow
                                        blurRadius: 6.r,
                                        offset: Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _isAddingToCart
                                      ? Center(
                                          child: SizedBox(
                                            width: 16.r,
                                            height: 16.r,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<
                                                    Color
                                                  >(Colors.white),
                                            ),
                                          ),
                                        )
                                      : ValueListenableBuilder<int>(
                                          valueListenable: _quantityNotifier,
                                          builder: (context, qty, _) {
                                            return Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .add_shopping_cart_rounded,
                                                  color: Colors.white,
                                                  size: 16.sp, // Reduced
                                                ),
                                                if (qty > 0)
                                                  Positioned(
                                                    top: 4,
                                                    right: 4,
                                                    child: Container(
                                                      width: 14.w, // Reduced
                                                      height: 14.h,
                                                      decoration:
                                                          BoxDecoration(
                                                            color: Colors.red,
                                                            shape: BoxShape
                                                                .circle,
                                                            border: Border.all(
                                                              color: Colors
                                                                  .white,
                                                              width: 1.w,
                                                            ),
                                                          ),
                                                      child: Center(
                                                        child: FittedBox(
                                                          child: Text(
                                                            qty > 9
                                                                ? '9+'
                                                                : qty.toString(),
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .white,
                                                              fontSize: 7
                                                                  .sp, // Reduced
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                            ),
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
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
