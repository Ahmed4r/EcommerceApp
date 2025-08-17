import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/homepage/product_details.dart';
import 'package:shop/utils/custom_page_routes.dart';

import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

class WishlistPage extends StatelessWidget {
  static const String routeName = "/wishlist";

  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: state.favorites.isEmpty
              ? Color(0xffEDF1F4)
              : AppColors.primary,
          appBar: AppBar(
            forceMaterialTransparency: true,
            backgroundColor: state.favorites.isEmpty
                ? Color(0xffEDF1F4)
                : AppColors.primary,
            title: Text(
              "Wishlist (${state.favorites.length})",
              style: GoogleFonts.cairo(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              if (state.favorites.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: () {
                    // Reload wishlist from Supabase
                    context.read<WishlistCubit>().loadFavorites();
                  },
                ),
            ],
          ),
          body: state.favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        FontAwesomeIcons.heart,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        "No favorite items yet",
                        style: GoogleFonts.cairo(
                          fontSize: 20.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        "Items you add to your wishlist will appear here",
                        style: GoogleFonts.cairo(
                          fontSize: 14.sp,
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await context.read<WishlistCubit>().loadFavorites();
                  },
                  child: GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: state.favorites.length,
                    itemBuilder: (context, index) {
                      final product = state.favorites[index];
                      return Stack(
                        children: [
                          Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        HeroPageRoute(
                                          child: ProductDetailsPage(
                                            product: product,
                                            heroTag:
                                                "wishlist_${product.name}_$index",
                                          ),
                                        ),
                                      );
                                    },
                                    child: Hero(
                                      tag: "wishlist_${product.name}_$index",
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.vertical(
                                          top: Radius.circular(12.r),
                                        ),
                                        child: Image.network(
                                          product.image.isNotEmpty
                                              ? product.image
                                              : 'https://lightwidget.com/wp-content/uploads/localhost-file-not-found.jpg',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey[200],
                                                child: Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey[400],
                                                  size: 48.sp,
                                                ),
                                              ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 5.h),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                  ),
                                  child: Text(
                                    product.name,
                                    style: GoogleFonts.cairo(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  "\$${product.price}",
                                  style: TextStyle(
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 5.h),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                context.read<WishlistCubit>().toggleFavorite(
                                  product,
                                );
                              },
                              child: CircleAvatar(
                                radius: 14.r,
                                backgroundColor: Colors.red.withOpacity(0.9),
                                child: FaIcon(
                                  FontAwesomeIcons.heart,
                                  color: Colors.white,
                                  size: 12.sp,
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
    );
  }
}
