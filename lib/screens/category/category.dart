import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/homepage/cubit/homepage_cubit.dart';
import 'package:shop/screens/homepage/cubit/homepage_state.dart';
import 'package:shop/widgets/product_card.dart';
// import 'package:shop/widgets/product_card.dart'; // Unused import

class Category extends StatefulWidget {
  static const String routeName = 'category';

  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final TextEditingController searchController = TextEditingController();
  // Remove local cubit instance - use the one from BlocProvider

  int selectedIndex = 0; // Start with "All" selected
  List<dynamic> filteredProducts = [];
  String searchQuery = '';
  List<Map<String, dynamic>> categoryData = [
    {"type": "text", "label": "All", "icon": null, "category": null},
    {
      "type": "icon",
      "label": "Bags",
      "icon": FontAwesomeIcons.bagShopping,
      "category": "Bags",
    },
    {
      "type": "icon",
      "label": "Clothing",
      "icon": FontAwesomeIcons.shirt,
      "category": "Clothing",
    },
    {
      "type": "icon",
      "label": "Electronics",
      "icon": FontAwesomeIcons.headphones,
      "category": "Electronics",
    },
    {
      "type": "icon",
      "label": "Accessories",
      "icon": FontAwesomeIcons.gem,
      "category": "Accessories",
    },
    {
      "type": "icon",
      "label": "Footwear",
      "icon": FontAwesomeIcons.shoePrints,
      "category": "Footwear",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Initialize data when category page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cubit = context.read<HomepageCubit>();
      cubit.fetchProductsFromFirebase();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterProducts(List<dynamic> allProducts) {
    String search = searchQuery.trim().toLowerCase();
    String? selectedCategory = selectedIndex > 0
        ? categoryData[selectedIndex]["category"]
        : null;

    setState(() {
      filteredProducts = allProducts.where((item) {
        final matchesSearch =
            search.isEmpty ||
            item.name.toLowerCase().contains(search) ||
            item.description.toLowerCase().contains(search) ||
            item.category.toLowerCase().contains(search);
        final matchesCategory =
            selectedCategory == null || item.category == selectedCategory;
        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  // void filterProducts(BuildContext context, String query) {
  //   final cubit = BlocProvider.of<HomepageCubit>(context);
  //   String search = query.trim().toLowerCase();
  //   String? selectedCategory = selectedIndex > 0
  //       ? categoryData[selectedIndex]["category"]
  //       : null;
  //   final filtered = cubit.state.products.where((item) {
  //     final matchesSearch =
  //         search.isEmpty ||
  //         item.name.toLowerCase().contains(search) ||
  //         item.description.toLowerCase().contains(search) ||
  //         item.category.toLowerCase().contains(search);
  //     final matchesCategory =
  //         selectedCategory == null || item.category == selectedCategory;
  //     return matchesSearch && matchesCategory;
  //   }).toList();
  //   cubit.emit(cubit.state.copyWith(filteredItems: filtered));
  // }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomepageCubit, HomepageState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.primary,
          appBar: AppBar(
            excludeHeaderSemantics: true,

            elevation: 0,
            title: Text(
              "Category",
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.transparent,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Glassy Search Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.4),
                            width: 1.5.w,
                          ),
                        ),
                        child: TextField(
                          onChanged: (query) {
                            searchQuery = query;
                            if (state is HomepageSuccess) {
                              filterProducts(state.products);
                            }
                          },
                          controller: searchController,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            labelText: 'Search',
                            labelStyle: GoogleFonts.cairo(
                              color: Colors.black54,
                            ),
                            prefixIcon: Icon(
                              FontAwesomeIcons.magnifyingGlass,
                              size: 20.r,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 15.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Shop By Category",
                        style: GoogleFonts.cairo(
                          color: Colors.black,
                          fontSize: 16.sp,
                        ),
                      ),
                      Spacer(),
                    ],
                  ),
                  SizedBox(height: 15.h),

                  SizedBox(
                    height: 50.h,
                    child: ListView.separated(
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 10.w),
                      scrollDirection: Axis.horizontal,
                      itemCount: categoryData.length,
                      itemBuilder: (context, index) {
                        bool isSelected = selectedIndex == index;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedIndex = index;
                            });
                            if (state is HomepageSuccess) {
                              filterProducts(state.products);
                            }
                          },

                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: EdgeInsets.symmetric(
                              horizontal: 22.w,
                              vertical: 15.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60.r),
                              color: isSelected
                                  ? Colors.blueAccent
                                  : Colors.white,
                            ),
                            child: categoryData[index]["type"] == "text"
                                ? Text(
                                    categoryData[index]["label"],
                                    style: GoogleFonts.cairo(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 16.sp,
                                    ),
                                  )
                                : isSelected
                                ? Row(
                                    mainAxisSize: MainAxisSize
                                        .min, // العرض على قد المحتوى
                                    children: [
                                      FaIcon(
                                        categoryData[index]["icon"],
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.black,
                                        size: 16.r,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        categoryData[index]["label"],
                                        style: GoogleFonts.cairo(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  )
                                : FaIcon(
                                    categoryData[index]["icon"],
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black,
                                    size: 16.r,
                                  ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Handle different states
                  if (state is HomepageLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (state is HomepageFailure)
                    Center(
                      child: Column(
                        children: [
                          Text('Error: ${state.error}'),
                          ElevatedButton(
                            onPressed: () {
                              context
                                  .read<HomepageCubit>()
                                  .fetchProductsFromFirebase();
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (state is HomepageSuccess)
                    Builder(
                      builder: (context) {
                        // Initialize filtered products if not done yet
                        if (filteredProducts.isEmpty &&
                            state.products.isNotEmpty) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            filterProducts(state.products);
                          });
                        }

                        final productsToShow = filteredProducts.isEmpty
                            ? state.products
                            : filteredProducts;

                        if (productsToShow.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: EdgeInsets.all(20.0.r),
                              child: Text(
                                'No products found',
                                style: GoogleFonts.cairo(
                                  fontSize: 16.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 10.h,
                                crossAxisSpacing: 10.w,
                                childAspectRatio: 3 / 4,
                              ),
                          itemCount: productsToShow.length,
                          itemBuilder: (context, index) {
                            if (index < productsToShow.length) {
                              return buildItemCard(
                                context,
                                productsToShow[index],
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        );
                      },
                    )
                  else
                    const Center(child: Text('No data available')),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
