import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

    // Get screen dimensions for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth > 600;
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Responsive card dimensions - fine-tuned to prevent overflow
    double cardWidth = isTablet
        ? (isLandscape ? screenWidth * 0.22 : screenWidth * 0.3)
        : screenWidth * 0.43;
    double cardHeight = isTablet
        ? (isLandscape ? screenHeight * 0.38 : screenHeight * 0.28)
        : screenHeight * 0.23; // Further reduced to 0.23

    // Ensure minimum dimensions - fine-tuned
    cardWidth = cardWidth.clamp(150.0, 220.0);
    cardHeight = cardHeight.clamp(175.0, 235.0); // Reduced by 5px

    // Responsive spacing and sizes - optimized
    final margin = isTablet ? 12.0 : 7.0; // Reduced margin
    final padding = isTablet ? 15.0 : 10.0; // Reduced padding
    final borderRadius = isTablet ? 24.0 : 20.0;
    final imageBorderRadius = isTablet ? 20.0 : 16.0;

    // Add validation for required product fields
    if (widget.product.id.isEmpty || widget.product.name.isEmpty) {
      return Container(
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.grey[300],
        ),
        child: Center(
          child: Text(
            'Product data incomplete',
            style: GoogleFonts.sen(
              fontSize: isTablet ? 14 : 12,
              color: Colors.grey[600],
            ),
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
        width: cardWidth,
        height: cardHeight,
        margin: EdgeInsets.all(margin),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: isDarkMode
                  ? Colors.black.withOpacity(0.3)
                  : Colors.grey.withOpacity(0.1),
              blurRadius: isTablet ? 20 : 15,
              offset: Offset(0, isTablet ? 8 : 5),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Discount Badge
            Expanded(
              flex: isLandscape ? 4 : 3,
              child: Stack(
                children: [
                  // Product Image
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.all(padding),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(imageBorderRadius),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(imageBorderRadius),
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
                                size: isTablet ? 50 : 40,
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
                      top: isTablet ? 12 : 8,
                      right: isTablet ? 12 : 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isTablet ? 10 : 8,
                          vertical: isTablet ? 6 : 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(
                            isTablet ? 16 : 12,
                          ),
                        ),
                        child: Text(
                          '-$discountPercent%',
                          style: GoogleFonts.sen(
                            color: Colors.white,
                            fontSize: isTablet ? 12 : 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Interactive Wishlist Button
                  Positioned(
                    top: isTablet ? 12 : 8,
                    left: isTablet ? 12 : 8,
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
                                width: isTablet ? 40 : 32,
                                height: isTablet ? 40 : 32,
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
                                      blurRadius: isTablet ? 6 : 4,
                                      offset: Offset(0, isTablet ? 3 : 2),
                                    ),
                                  ],
                                ),
                                child: _isTogglingWishlist
                                    ? SizedBox(
                                        width: isTablet ? 16 : 12,
                                        height: isTablet ? 16 : 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          color: Colors.red,
                                        ),
                                      )
                                    : Icon(
                                        _isInWishlist
                                            ? Icons.favorite_rounded
                                            : Icons.favorite_border_rounded,
                                        size: isTablet ? 22 : 18,
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
            Expanded(
              flex: isLandscape ? 3 : 2,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  padding,
                  0,
                  padding,
                  padding * 0.6,
                ), // Further reduced bottom padding
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.min, // Added to prevent overflow
                  children: [
                    // Product Name and Rating - Compact layout
                    Flexible(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.product.name,
                            style: GoogleFonts.sen(
                              fontSize: isTablet ? 15 : 13, // Slightly reduced
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black87,
                            ),
                            maxLines: 1, // Always 1 line to save space
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(
                            height: isTablet ? 1 : 0.5,
                          ), // Minimal spacing
                          Text(
                            widget.product.brand,
                            style: GoogleFonts.sen(
                              fontSize: isTablet ? 11 : 9, // Further reduced
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isTablet ? 3 : 1), // Minimal spacing
                          // Enhanced Rating Display
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isTablet ? 6 : 4, // Reduced padding
                              vertical: isTablet ? 3 : 2, // Reduced padding
                            ),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                isTablet ? 12 : 10,
                              ),
                              border: Border.all(
                                color: Colors.amber.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.star_rounded,
                                  size: isTablet ? 16 : 14,
                                  color: Colors.amber[700],
                                ),
                                SizedBox(width: isTablet ? 4 : 3),
                                Text(
                                  widget.product.rate.toStringAsFixed(1),
                                  style: GoogleFonts.sen(
                                    fontSize: isTablet ? 13 : 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.amber[800],
                                  ),
                                ),
                                SizedBox(width: isTablet ? 4 : 3),
                                Text(
                                  '(${widget.product.reviewsCount})',
                                  style: GoogleFonts.sen(
                                    fontSize: isTablet ? 11 : 9,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isTablet ? 2 : 1), // Minimal spacing
                    // Price and Cart Section - Compact layout
                    Flexible(
                      flex: 1,
                      child: Row(
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
                                      fontSize: isTablet
                                          ? 16
                                          : 14, // Slightly reduced
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
                                        fontSize: isTablet ? 12 : 10, // Reduced
                                        color: Colors.grey[500],
                                        decoration: TextDecoration.lineThrough,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          SizedBox(width: 6), // Reduced spacing
                          // Add to Cart Button - Smaller to fit better
                          GestureDetector(
                            onTap: _addToCart,
                            child: AnimatedBuilder(
                              animation: _scaleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _scaleAnimation.value,
                                  child: Container(
                                    width: isTablet ? 46 : 38, // Reduced size
                                    height: isTablet ? 46 : 38,
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
                                        isTablet ? 16 : 12,
                                      ), // Reduced
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor
                                              .withOpacity(
                                                0.2,
                                              ), // Reduced shadow
                                          blurRadius: isTablet ? 8 : 6,
                                          offset: Offset(0, isTablet ? 4 : 3),
                                        ),
                                      ],
                                    ),
                                    child: _isAddingToCart
                                        ? Center(
                                            child: SizedBox(
                                              width: isTablet ? 20 : 16,
                                              height: isTablet ? 20 : 16,
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
                                                    size: isTablet
                                                        ? 20
                                                        : 16, // Reduced
                                                  ),
                                                  if (qty > 0)
                                                    Positioned(
                                                      top: isTablet ? 6 : 4,
                                                      right: isTablet ? 6 : 4,
                                                      child: Container(
                                                        width: isTablet
                                                            ? 18
                                                            : 14, // Reduced
                                                        height: isTablet
                                                            ? 18
                                                            : 14,
                                                        decoration:
                                                            BoxDecoration(
                                                              color: Colors.red,
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border.all(
                                                                color: Colors
                                                                    .white,
                                                                width: 1,
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
                                                                fontSize:
                                                                    isTablet
                                                                    ? 9
                                                                    : 7, // Reduced
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
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Function version (if you prefer to keep it as a function)
Widget buildItemCard(BuildContext context, Product obj) {
  return ProductItemCard(product: obj);
}
