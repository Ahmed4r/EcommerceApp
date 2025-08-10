import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product.dart';
import 'package:shop/widgets/product_card.dart';

class Category extends StatefulWidget {
  static const String routeName = 'category';
  const Category({super.key});

  @override
  State<Category> createState() => _CategoryState();
}

class _CategoryState extends State<Category> {
  final TextEditingController searchController = TextEditingController();
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

  List<Product> filteredItems = [];
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    filteredItems = List.from(products);
  }

  void applyFilters() {
    String query = searchController.text.trim().toLowerCase();
    String? selectedCategory = selectedIndex > 0
        ? categoryData[selectedIndex]["category"]
        : null;

    setState(() {
      filteredItems = products.where((item) {
        final matchesSearch =
            query.isEmpty ||
            item.name.toLowerCase().contains(query) ||
            item.description.toLowerCase().contains(query) ||
            item.category.toLowerCase().contains(query);

        final matchesCategory =
            selectedCategory == null || item.category == selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void filterSearchResults(String query) {
    applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffEDF1F4),
      appBar: AppBar(
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
                      onChanged: filterSearchResults,
                      controller: searchController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Search',
                        labelStyle: GoogleFonts.cairo(color: Colors.black54),
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
                  separatorBuilder: (context, index) => SizedBox(width: 10.w),
                  scrollDirection: Axis.horizontal,
                  itemCount: categoryData.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                        applyFilters();
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: EdgeInsets.symmetric(
                          horizontal: 22.w,
                          vertical: 15.h,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60.r),
                          color: isSelected ? Colors.blueAccent : Colors.white,
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
                                mainAxisSize:
                                    MainAxisSize.min, // العرض على قد المحتوى
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
                                color: isSelected ? Colors.white : Colors.black,
                                size: 16.r,
                              ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 15.h),
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // عدد الكروت في كل صف
                  mainAxisSpacing: 10.h,
                  crossAxisSpacing: 10.w,
                  childAspectRatio: 3 / 4, // نسبة العرض للطول حسب شكل الكرت
                ),
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  return buildItemCard(context, filteredItems[index]);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
