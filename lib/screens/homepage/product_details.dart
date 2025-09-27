import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:shop/model/product_model.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';
import 'package:shop/widgets/animated_page_wrapper.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;
  final String? heroTag;

  const ProductDetailsPage({super.key, required this.product, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return AnimatedPageWrapper(
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Column(
            children: [
              // ===== AppBar =====
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: _circleButton(context, Icons.arrow_back_ios_new),
                    ),
                    GestureDetector(
                      onTap: () {
                        CartManager().addToCart(product);

                        ScaffoldMessenger.of(context).showSnackBar(
                          snackBarAnimationStyle: AnimationStyle(
                            curve: Curves.fastOutSlowIn,
                            duration: Duration(milliseconds: 500),
                          ),
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text('${product.name} added to cart'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      child: _circleButton(context, Icons.add_shopping_cart),
                    ),
                  ],
                ),
              ),

              // ===== Product Image =====
              Hero(
                tag:
                    heroTag ??
                    "product_${product.name}", // Use provided tag or default
                child: Container(
                  width: double.infinity,
                  height: 280.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.r),
                    image: DecorationImage(
                      image: NetworkImage(
                        product.image.isNotEmpty
                            ? product.image
                            : 'https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg',
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // ===== Product Info =====
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(25.r),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                product.name,
                                style: GoogleFonts.cairo(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 22.r,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  product.rate.toString(),
                                  style: GoogleFonts.cairo(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),

                        // Price
                        Text(
                          "\$ ${product.price}",
                          style: GoogleFonts.cairo(
                            fontSize: 22.sp,
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Description
                        Text(
                          product.description,
                          style: GoogleFonts.cairo(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Add to Wishlist Button
                        BlocBuilder<WishlistCubit, WishlistState>(
                          builder: (context, state) {
                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  context.read<WishlistCubit>().toggleFavorite(
                                    product,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.r),
                                  ),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "Add to Wishlist",
                                      style: GoogleFonts.cairo(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onPrimary,
                                      ),
                                    ),

                                    Icon(
                                      context.read<WishlistCubit>().isFavorite(
                                            product,
                                          )
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color:
                                          context
                                              .read<WishlistCubit>()
                                              .isFavorite(product)
                                          ? Colors.red
                                          : Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          bloc: context.read<WishlistCubit>(),
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

  Widget _circleButton(BuildContext context, IconData icon, {Color? color}) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 20.r,
        color: color ?? Theme.of(context).iconTheme.color,
      ),
    );
  }
}
