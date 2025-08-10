import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
            appBar: AppBar(title: Text("Wishlist")),
            body: Center(child: Text("No favorite items yet")),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xffEDF1F4),
          appBar: AppBar(
            backgroundColor: const Color(0xffEDF1F4),
            title: Text("Wishlist"),
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
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.asset(product.image, fit: BoxFit.cover),
                        ),
                        Text(product.name),
                        Text("\$${product.price}"),
                      ],
                    ),
                  ),
                  Positioned(
                    child: GestureDetector(
                      onTap: () {
                        context.read<WishlistCubit>().toggleFavorite(product);
                      },
                      child: FaIcon(FontAwesomeIcons.remove, color: Colors.red),
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
