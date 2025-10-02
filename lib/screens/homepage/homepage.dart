import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/screens/cart/cart_Screen.dart';
import 'package:shop/widgets/product_card.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'cubit/homepage_cubit.dart';
import 'cubit/homepage_state.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';

class Homepage extends StatefulWidget {
  static const String routeName = 'home';

  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Map<String, dynamic>> categoryData = [
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
    // Load data when homepage initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomepageCubit>().loadUserData();
      context.read<HomepageCubit>().fetchProductsFromFirebase();
      // Load wishlist data to ensure sync
      context.read<WishlistCubit>().loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomepageCubit, HomepageState>(
      builder: (context, state) {
        if (state is HomepageLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator.adaptive()),
          );
        }
        if (state is HomepageFailure) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 50.r, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading products',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Error: ${state.error}',
                    style: GoogleFonts.cairo(fontSize: 14.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<HomepageCubit>().fetchProductsFromFirebase();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }
        if (state is HomepageSuccess) {
          final userName = context.read<HomepageCubit>().userName;
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              centerTitle: false,
              title: Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22.r,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).primaryColor,
                        size: 24.r,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back! 👋',
                            style: GoogleFonts.sen(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            userName != null && userName.isNotEmpty
                                ? userName
                                : 'Guest User',
                            style: GoogleFonts.sen(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                // Notification Button
                Container(
                  margin: EdgeInsets.only(right: 6.w),
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notifications coming soon!')),
                      );
                    },
                    icon: Icon(Icons.notifications_outlined, size: 18.r),
                    padding: EdgeInsets.zero,
                  ),
                ),
                // Cart Button
                Container(
                  margin: EdgeInsets.only(right: 12.w),
                  width: 40.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, CartScreen.routeName),
                    icon: Icon(Icons.shopping_bag_outlined, size: 18.r),
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await context.read<HomepageCubit>().fetchProductsFromFirebase();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Bar Section
                    // _buildSearchBar(context),
                    // SizedBox(height: 24.h),

                    // Banner Carousel
                    _buildBannerSection(),
                    SizedBox(height: 24.h),

                    // Categories Section
                    _buildCategoriesSection(context),
                    SizedBox(height: 24.h),

                    // Featured Deals Section
                    _buildDealsSection(state.products),
                    SizedBox(height: 24.h),

                    // Products Section Header
                    _buildSectionHeader(
                      "Popular Products",
                      "Trending items this week",
                      onSeeAll: () {
                        if (state.products.isNotEmpty) {
                          Navigator.pushNamed(
                            context,
                            '/products',
                            arguments: state.products,
                          );
                        }
                      },
                    ),
                    SizedBox(height: 16.h),

                    // Products Grid
                    state.products.isNotEmpty
                        ? GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16.h,
                                  crossAxisSpacing: 16.w,
                                  childAspectRatio:
                                      0.7, // Adjusted to prevent overflow
                                ),
                            itemCount: state.products.length > 6
                                ? 6
                                : state.products.length,
                            itemBuilder: (_, index) {
                              return ProductItemCard(
                                product: state.products[index],
                              );
                            },
                          )
                        : _buildEmptyState(),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Enhanced Search Bar
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 52.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for products...',
          hintStyle: GoogleFonts.sen(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 14.sp,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.6),
            size: 20.r,
          ),
          suffixIcon: Container(
            margin: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.tune,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 18.r,
            ),
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            // Implement search functionality
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Searching for: $query')));
          }
        },
      ),
    );
  }

  // Enhanced Banner Section
  Widget _buildBannerSection() {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20.r),
        child: CarouselSlider(
          items:
              [
                "assets/banners/banner1.png",
                "assets/banners/banner2.png",
                "assets/banners/banner3.avif",
              ].map((i) {
                return Builder(
                  builder: (context) => Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.high,
                        image: AssetImage(i),
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
          options: CarouselOptions(
            height: 180.h,
            autoPlay: true,
            enlargeCenterPage: true,
            autoPlayCurve: Curves.easeInOut,
            autoPlayInterval: const Duration(seconds: 4),
            viewportFraction: 1.0,
          ),
        ),
      ),
    );
  }

  // Enhanced Categories Section
  Widget _buildCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Category',
          style: GoogleFonts.sen(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 90.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categoryData.length,
            itemBuilder: (context, index) {
              final category = categoryData[index];
              return Container(
                width: 75.w,
                margin: EdgeInsets.only(right: 10.w),
                child: Column(
                  children: [
                    Container(
                      width: 55.w,
                      height: 55.h,
                      decoration: BoxDecoration(
                        color: index == 0
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(18.r),
                        border: index == 0
                            ? null
                            : Border.all(
                                color: Theme.of(
                                  context,
                                ).dividerColor.withOpacity(0.3),
                                width: 1,
                              ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).shadowColor.withOpacity(0.1),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: category["icon"] != null
                          ? Icon(
                              category["icon"],
                              color: index == 0
                                  ? Colors.white
                                  : Theme.of(context).primaryColor,
                              size: 20.r,
                            )
                          : Icon(Icons.apps, color: Colors.white, size: 20.r),
                    ),
                    SizedBox(height: 6.h),
                    Flexible(
                      child: Text(
                        category["label"],
                        style: GoogleFonts.sen(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: index == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Deals Section
  Widget _buildDealsSection(List products) {
    final dealsProducts = products
        .where((p) => p.oldPrice != null)
        .take(3)
        .toList();

    if (dealsProducts.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.local_fire_department, color: Colors.orange, size: 20.r),
            SizedBox(width: 8.w),
            Text(
              'Hot Deals 🔥',
              style: GoogleFonts.sen(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                'Limited Time',
                style: GoogleFonts.sen(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 120.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dealsProducts.length,
            itemBuilder: (context, index) {
              final product = dealsProducts[index];
              final discount =
                  ((product.oldPrice - product.price) / product.oldPrice * 100)
                      .round();
              return Container(
                width: 180.w,
                margin: EdgeInsets.only(right: 10.w),
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.withOpacity(0.1),
                      Colors.red.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Image.network(
                        product.image,
                        width: 50.w,
                        height: 50.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 50.w,
                          height: 50.w,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 20.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            product.name,
                            style: GoogleFonts.sen(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 3.h),
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  '\$${product.price.toStringAsFixed(2)}',
                                  style: GoogleFonts.sen(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Flexible(
                                child: Text(
                                  '\$${product.oldPrice.toStringAsFixed(2)}',
                                  style: GoogleFonts.sen(
                                    fontSize: 11.sp,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey[500],
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 4.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              '$discount% OFF',
                              style: GoogleFonts.sen(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Section Header with subtitle
  Widget _buildSectionHeader(
    String title,
    String subtitle, {
    VoidCallback? onSeeAll,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.sen(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: GoogleFonts.sen(
                  fontSize: 12.sp,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
        if (onSeeAll != null)
          TextButton.icon(
            onPressed: onSeeAll,
            icon: Text(
              'See All',
              style: GoogleFonts.sen(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            label: Icon(
              Icons.arrow_forward_ios,
              size: 12.r,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }

  // Enhanced Empty State
  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(32.r),
      child: Column(
        children: [
          Container(
            width: 120.w,
            height: 120.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 60.r,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'No Products Available',
            style: GoogleFonts.sen(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Check back later for amazing products\nand exclusive deals!',
            style: GoogleFonts.sen(
              fontSize: 14.sp,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              context.read<HomepageCubit>().fetchProductsFromFirebase();
            },
            icon: Icon(Icons.refresh),
            label: Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep the original sliderWidget for backward compatibility
Widget sliderWidget() {
  return CarouselSlider(
    items:
        [
          "assets/banners/banner1.png",
          "assets/banners/banner2.png",
          "assets/banners/banner3.avif",
        ].map((i) {
          return Builder(
            builder: (context) => Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0.w),
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.high,
                  image: AssetImage(i),
                ),
              ),
            ),
          );
        }).toList(),
    options: CarouselOptions(
      height: 130.h,
      autoPlay: true,
      enlargeCenterPage: true,
      autoPlayCurve: Curves.easeInOut,
      autoPlayInterval: const Duration(seconds: 3),
    ),
  );
}
