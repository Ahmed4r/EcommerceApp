import 'dart:developer';

import 'package:carousel_slider_plus/carousel_slider_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product.dart';
import 'package:shop/widgets/homepage_headers.dart';
import 'package:shop/widgets/product_card.dart';

class Homepage extends StatefulWidget {
  static const String routeName = 'home';
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final List<Product> products = [
    Product(
      id: "1",
      name: "Handbag",
      description: "Elegant leather handbag perfect for casual and formal use.",
      image: "assets/handbag.jpg",

      price: 28.0,
      oldPrice: 35.0,
      discount: 20.0,
      rate: 3.5,
      reviewsCount: 120,
      category: "Bags",
      brand: "FashionCo",
      inStock: true,
      tags: ["bag", "leather", "fashion"],
      createdAt: DateTime(2025, 1, 1),
      updatedAt: DateTime(2025, 1, 5),
      variations: {
        "color": ["black", "brown"],
        "size": ["small", "medium"],
      },
    ),
    Product(
      id: "2",
      name: "Hoodie",
      description: "Warm and comfortable hoodie for everyday wear.",
      image: "assets/hoddy.jpg",

      price: 58.0,
      oldPrice: 70.0,
      discount: 17.0,
      rate: 2.5,
      reviewsCount: 80,
      category: "Clothing",
      brand: "UrbanWear",
      inStock: true,
      tags: ["hoodie", "winter", "casual"],
      createdAt: DateTime(2025, 1, 2),
      updatedAt: DateTime(2025, 1, 6),
      variations: {
        "color": ["black", "grey"],
        "size": ["M", "L", "XL"],
      },
    ),
    Product(
      id: "3",
      name: "Headphones",
      description: "High-quality wireless headphones with noise cancellation.",
      image: "assets/headphones.jpg",

      price: 88.0,
      oldPrice: 110.0,
      discount: 20.0,
      rate: 4.5,
      reviewsCount: 200,
      category: "Electronics",
      brand: "SoundMax",
      inStock: true,
      tags: ["headphones", "audio", "wireless"],
      createdAt: DateTime(2025, 1, 3),
      updatedAt: DateTime(2025, 1, 7),
      variations: {
        "color": ["black", "white"],
      },
    ),
    Product(
      id: "4",
      name: "Classic Watch",
      description: "Stylish classic watch with leather strap.",
      image: "assets/classic watch.jpg",

      price: 88.0,
      oldPrice: 100.0,
      discount: 12.0,
      rate: 3.1,
      reviewsCount: 90,
      category: "Accessories",
      brand: "TimeLux",
      inStock: true,
      tags: ["watch", "leather", "classic"],
      createdAt: DateTime(2025, 1, 4),
      updatedAt: DateTime(2025, 1, 8),
      variations: {
        "color": ["black", "brown"],
      },
    ),
    Product(
      id: "5",
      name: "T-Shirt",
      description: "Soft cotton t-shirt, perfect for casual wear.",
      image: "assets/t-shirt.jpg",

      price: 88.0,
      oldPrice: 95.0,
      discount: 7.0,
      rate: 3.9,
      reviewsCount: 150,
      category: "Clothing",
      brand: "CottonWorld",
      inStock: true,
      tags: ["t-shirt", "casual", "cotton"],
      createdAt: DateTime(2025, 1, 5),
      updatedAt: DateTime(2025, 1, 9),
      variations: {
        "color": ["white", "blue"],
        "size": ["S", "M", "L"],
      },
    ),
    Product(
      id: "6",
      name: "Shoes",
      description: "Durable running shoes with breathable material.",
      image: "assets/shoes.jpg",

      price: 88.0,
      oldPrice: 120.0,
      discount: 27.0,
      rate: 2.7,
      reviewsCount: 60,
      category: "Footwear",
      brand: "RunFast",
      inStock: true,
      tags: ["shoes", "running", "sports"],
      createdAt: DateTime(2025, 1, 6),
      updatedAt: DateTime(2025, 1, 10),
      variations: {
        "color": ["black", "white"],
        "size": ["40", "41", "42", "43"],
      },
    ),
    Product(
      id: "7",
      name: "Jeans",
      description: "Comfortable slim-fit jeans with stretch fabric.",
      image: "assets/jeans.jpg",

      price: 88.0,
      oldPrice: 99.0,
      discount: 11.0,
      rate: 2.2,
      reviewsCount: 75,
      category: "Clothing",
      brand: "DenimPro",
      inStock: true,
      tags: ["jeans", "denim", "casual"],
      createdAt: DateTime(2025, 1, 7),
      updatedAt: DateTime(2025, 1, 11),
      variations: {
        "color": ["blue", "black"],
        "size": ["30", "32", "34"],
      },
    ),
    Product(
      id: "8",
      name: "Dress",
      description: "Elegant evening dress made from premium fabric.",
      image: "assets/dress.jpg",

      price: 88.0,
      oldPrice: 130.0,
      discount: 32.0,
      rate: 1.6,
      reviewsCount: 40,
      category: "Clothing",
      brand: "GlamourWear",
      inStock: true,
      tags: ["dress", "evening", "fashion"],
      createdAt: DateTime(2025, 1, 8),
      updatedAt: DateTime(2025, 1, 12),
      variations: {
        "color": ["red", "black"],
        "size": ["S", "M", "L"],
      },
    ),
    Product(
      id: "9",
      name: "Jacket",
      description: "Warm winter jacket with waterproof coating.",
      image: "assets/jacket.jpg",

      price: 88.0,
      oldPrice: 140.0,
      discount: 37.0,
      rate: 2.2,
      reviewsCount: 85,
      category: "Clothing",
      brand: "ColdShield",
      inStock: true,
      tags: ["jacket", "winter", "coat"],
      createdAt: DateTime(2025, 1, 9),
      updatedAt: DateTime(2025, 1, 13),
      variations: {
        "color": ["black", "grey"],
        "size": ["M", "L", "XL"],
      },
    ),
    Product(
      id: "10",
      name: "Earring",
      description: "Stylish silver earrings for all occasions.",
      image: "assets/earings.jpg",

      price: 88.0,
      oldPrice: 105.0,
      discount: 16.0,
      rate: 3.5,
      reviewsCount: 110,
      category: "Accessories",
      brand: "ShineBright",
      inStock: true,
      tags: ["earring", "silver", "jewelry"],
      createdAt: DateTime(2025, 1, 10),
      updatedAt: DateTime(2025, 1, 14),
      variations: {
        "color": ["silver"],
        "size": ["standard"],
      },
    ),
  ];

  int selectedIndex = -1;
  List<Map<String, dynamic>> categoryData = [
    {"type": "text", "label": "All", "icon": null},
    {"type": "icon", "label": "woman", "icon": FontAwesomeIcons.personDress},
    {"type": "icon", "label": "man", "icon": FontAwesomeIcons.person},
    {"type": "icon", "label": "child", "icon": FontAwesomeIcons.faceSmile},
    {"type": "icon", "label": "tools", "icon": FontAwesomeIcons.utensils},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEDF1F4),
      appBar: AppBar(
        actionsPadding: EdgeInsets.all(8),

        backgroundColor: Color(0xffEDF1F4),
        leading: Padding(
          padding: EdgeInsets.only(left: 10.0.w),
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: AssetImage("assets/profile.jpg"),
          ),
        ),
        title: Column(
          children: [
            Text(
              'Hi Welcome',
              style: GoogleFonts.cairo(color: Colors.black, fontSize: 20.sp),
            ),
            Text(
              "Ahmed Hegazy",
              style: GoogleFonts.cairo(color: Colors.black, fontSize: 16.sp),
            ),
          ],
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.w),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: IconButton(
              onPressed: () {},
              icon: FaIcon(
                FontAwesomeIcons.bell,
                color: Colors.black,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1.w),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: IconButton(
              onPressed: () {
                
              },
              icon: FaIcon(
                color: Colors.black,
                FontAwesomeIcons.cartShopping,
                size: 20,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(8.0.r),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              // HomepageHeaders("Prodcut Category", true, products),

              // SizedBox(
              //   height: 50.h,
              //   child: ListView.separated(
              //     separatorBuilder: (context, index) => SizedBox(width: 10.w),
              //     scrollDirection: Axis.horizontal,
              //     itemCount: categoryData.length,
              //     itemBuilder: (context, index) {
              //       bool isSelected = selectedIndex == index;

              //       return GestureDetector(
              //         onTap: () {
              //           setState(() {
              //             selectedIndex = index;
              //           });
              //         },
              //         child: AnimatedContainer(
              //           duration: const Duration(milliseconds: 250),
              //           width: isSelected ? 90.w : 60.w,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(60.r),
              //             color: isSelected ? Colors.blueAccent : Colors.white,
              //           ),
              //           child: Center(
              //             child: categoryData[index]["type"] == "text"
              //                 ? Text(
              //                     categoryData[index]["label"],
              //                     style: GoogleFonts.cairo(
              //                       color: isSelected
              //                           ? Colors.white
              //                           : Colors.black,
              //                       fontSize: 16.sp,
              //                     ),
              //                   )
              //                 : Flexible(
              //                     child: isSelected
              //                         ? Row(
              //                             mainAxisAlignment:
              //                                 MainAxisAlignment.spaceAround,
              //                             children: [
              //                               FaIcon(
              //                                 categoryData[index]["icon"],
              //                                 color: isSelected
              //                                     ? Colors.white
              //                                     : Colors.black,
              //                                 size: 16.r,
              //                               ),
              //                               Text(
              //                                 categoryData[index]["label"],
              //                                 style: GoogleFonts.cairo(
              //                                   color: isSelected
              //                                       ? Colors.white
              //                                       : Colors.black,
              //                                   fontSize: 16.sp,
              //                                 ),
              //                               ),
              //                             ],
              //                           )
              //                         : FaIcon(
              //                             categoryData[index]["icon"],
              //                             color: isSelected
              //                                 ? Colors.white
              //                                 : Colors.black,
              //                             size: 16.r,
              //                           ),
              //                   ),
              //           ),
              //         ),
              //       );
              //     },
              //   ),
              // ),
              // SizedBox(height: 12.h),
              sliderWidget(),
              SizedBox(height: 12.h),
              HomepageHeaders("Popular Product", false, products),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عدد الكروت في كل صف
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 3 / 4, // نسبة العرض للطول حسب شكل الكرت
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return buildItemCard(context, products[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget sliderWidget() {
  return CarouselSlider(
    items:
        [
          "assets/classic watch.jpg",
          "assets/shoes.jpg",
          "assets/handbag.jpg",
        ].map((i) {
          return Builder(
            builder: (BuildContext context) {
              return Container(
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.symmetric(horizontal: 5.0.w),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    image: AssetImage(i),
                  ),
                ),
              );
            },
          );
        }).toList(),
    options: CarouselOptions(
      height: 130.h,
      aspectRatio: (16 / 9),
      viewportFraction: 0.8,
      initialPage: 0,
      enableInfiniteScroll: true,
      reverse: false,
      autoPlay: true,
      autoPlayInterval: Duration(seconds: 3),
      autoPlayAnimationDuration: Duration(milliseconds: 800),
      autoPlayCurve: Curves.fastOutSlowIn,
      enlargeCenterPage: true,
      enlargeFactor: 0.4,
      onPageChanged: (index, reason) {},
      scrollDirection: Axis.horizontal,
    ),
  );
}
