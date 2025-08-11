import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop/model/product.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

class ProductDetailsPage extends StatelessWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
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
                    child: _circleButton(Icons.arrow_back_ios_new),
                  ),

                  // BlocBuilder<WishlistCubit, WishlistState>(
                  //   builder: (context, state) {
                  //     final isFavorite = context
                  //         .read<WishlistCubit>()
                  //         .isFavorite(product);

                  //     return GestureDetector(
                  //       onTap: () {
                  //         context.read<WishlistCubit>().toggleFavorite(product);
                  //       },
                  //       child: _circleButton(
                  //         isFavorite ? Icons.favorite : Icons.favorite_border,
                  //         color: isFavorite ? Colors.red : Colors.black,
                  //       ),
                  //     );
                  //   },
                  // ),
                ],
              ),
            ),

            // ===== Product Image =====
            Hero(
              tag: product.name,
              child: Container(
                width: double.infinity,
                height: 280.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20.r),
                  image: DecorationImage(
                    image: AssetImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // ===== Product Info =====
            Expanded(
              child: Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                              Icon(Icons.star, color: Colors.amber, size: 22.r),
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
                        "This is a premium quality ${product.name} designed with modern style and comfort. "
                        "Perfect for your daily wear or special occasions. "
                        "Crafted with high quality materials to ensure durability and style.",
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
                                backgroundColor: Colors.black,
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
                                      color: Colors.white,
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
    );
  }

  Widget _circleButton(IconData icon, {Color color = Colors.black}) {
    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Icon(icon, size: 20.r, color: color),
    );
  }
}
