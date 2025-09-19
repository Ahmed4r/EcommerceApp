import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/cart/cart_Screen.dart';
import 'package:shop/widgets/homepage_headers.dart';
import 'package:shop/widgets/product_card.dart';
import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:shop/screens/orders/orders_page.dart';
import 'homepage_cubit.dart';
import 'homepage_state.dart';

class Homepage extends StatefulWidget {
  static const String routeName = 'home';

  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage>
    with AutomaticKeepAliveClientMixin {
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
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return BlocBuilder<HomepageCubit, HomepageState>(
      builder: (context, state) {
        if (state is HomepageInitial) {
          final cubit = context.read<HomepageCubit>();
          cubit.fetchProductsFromFirebase();
        }
        if (state is HomepageLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is HomepageFailure) {
          return Center(child: Text('Error: ${state.error}'));
        }
        if (state is HomepageSuccess) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            appBar: AppBar(
              toolbarHeight: 50.h,
              forceMaterialTransparency: true,
              backgroundColor: AppColors.primary,
              leading: Padding(
                padding: EdgeInsets.only(left: 10.0.w),
                // child: CircleAvatar(
                //   onBackgroundImageError: (_, __) {},
                //   radius: 50.r,
                //   // backgroundImage: state.image != null
                //   //     ? FileImage(File(state.image!))
                //   //     : const AssetImage('assets/profile.jpg') as ImageProvider,
                // ),
              ),
              centerTitle: false,
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hi Welcome', style: GoogleFonts.cairo(fontSize: 20.sp)),
                  Text(
                    //   name
                    '',
                    style: GoogleFonts.cairo(fontSize: 16.sp),
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    // Container(
                    //   margin: EdgeInsets.only(right: 8.w),
                    //   decoration: BoxDecoration(
                    //     border: Border.all(
                    //       color: Colors.grey.shade300,
                    //       width: 1.w,
                    //     ),
                    //     borderRadius: BorderRadius.circular(16.r),
                    //   ),
                    //   child: IconButton(
                    //     tooltip: 'My Orders',
                    //     onPressed: () =>
                    //         Navigator.pushNamed(context, OrdersPage.routeName),
                    //     icon: FaIcon(
                    //       FontAwesomeIcons.clipboardList,
                    //       size: 18.r,
                    //     ),
                    //   ),
                    // ),
                    Container(
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1.w,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: IconButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, CartScreen.routeName),
                        icon: FaIcon(FontAwesomeIcons.cartShopping, size: 20.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                await context.read<HomepageCubit>().fetchProductsFromFirebase();
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.all(8.0.r),
                child: Column(
                  children: [
                    SizedBox(
                      height: 50.h,
                      child: ListView.separated(
                        separatorBuilder: (_, __) => SizedBox(width: 10.w),
                        scrollDirection: Axis.horizontal,
                        itemCount: categoryData.length,
                        itemBuilder: (_, index) {
                          // bool isSelected = state.selectedIndex == index;
                          return GestureDetector(
                            onTap: () => null,
                            // cubit.selectCategory(index, categoryData),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: EdgeInsets.symmetric(
                                horizontal: 22.w,
                                vertical: 15.h,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(60.r),
                                // color: isSelected
                                //     ? Colors.blueAccent
                                //     : Colors.white,
                              ),

                              // child: categoryData[index]["type"] == "text"
                              //     ? Text(
                              //         categoryData[index]["label"],
                              //         style: GoogleFonts.cairo(
                              //           // color: isSelected
                              //           //     ? Colors.white
                              //           //     : Colors.black,
                              //         ),
                              //       )
                              // : isSelected
                              // ? Row(
                              //     mainAxisSize: MainAxisSize.min,
                              //     children: [
                              //       FaIcon(
                              //               categoryData[index]["icon"],
                              //               color: Colors.white,
                              //               size: 16.r,
                              //             ),
                              //             SizedBox(width: 6.w),
                              //             Text(
                              //               categoryData[index]["label"],
                              //               style: GoogleFonts.cairo(
                              //                 color: Colors.white,
                              //               ),
                              //             ),
                              //           ],
                              //         )
                              //       : FaIcon(
                              //           categoryData[index]["icon"],
                              //           color: Colors.black,
                              //           size: 16.r,
                              //         ),
                            ),
                          );
                        },
                      ),
                    ),
                    // SizedBox(height: 12.h),
                    sliderWidget(),
                    SizedBox(height: 12.h),
                    HomepageHeaders(
                      "Popular Product",
                      false,
                      state.products,
                      categoryData,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10.h,
                        crossAxisSpacing: 10.w,
                        childAspectRatio: 3 / 4,
                      ),
                      itemCount: state.products.length,

                      itemBuilder: (_, index) =>
                          buildItemCard(context, state.products[index]),
                    ),
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
}

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
