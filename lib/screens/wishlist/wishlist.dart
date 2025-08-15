import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/homepage/details.dart';

import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_state.dart';

class WishlistPage extends StatelessWidget {
  static const String routeName = "/wishlist";

  const WishlistPage({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WishlistCubit, WishlistState>(
      builder: (context, state) {
        if (state.favorites.isEmpty) {
          return Scaffold(
            backgroundColor: Color(0xffEDF1F4),
            appBar: AppBar(
              backgroundColor: Color(0xffEDF1F4),
              title: Text(
                "Wishlist",
                style: GoogleFonts.cairo(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Text(
                "No favorite items yet",
                style: GoogleFonts.cairo(
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            backgroundColor: AppColors.primary,
            title: Text(
              "Wishlist",
              style: GoogleFonts.cairo(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: GridView.builder(
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
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ProductDetailsPage(product: product),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(12.r),
                              ),
                              child: Image.network(
                                product.image,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (_, __, ___) => Image.asset(
                                  'assets/images/default_product.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 5.h),
                        Text(
                          product.name,
                          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "\$${product.price}",
                          style: TextStyle(color: Colors.green[700]),
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
                        context.read<WishlistCubit>().toggleFavorite(product);
                      },
                      child: CircleAvatar(
                        radius: 14.r,
                        backgroundColor: Colors.white,
                        child: FaIcon(
                          FontAwesomeIcons.remove,
                          color: Colors.red,
                          size: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
