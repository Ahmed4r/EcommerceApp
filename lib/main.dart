import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/screens/category/category.dart';
import 'package:shop/screens/homepage/homepage.dart';
import 'package:shop/screens/profile/editProfile.dart';
import 'package:shop/screens/profile/personal_info.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/screens/wishlist/wishlist.dart';
import 'package:shop/widgets/navigationbar.dart';

void main() {
  runApp(const ShopApp());
}

class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Navigationbar(key: navBarKey),
        initialRoute: Navigationbar.routeName,
        routes: {
          Homepage.routeName: (context) => Homepage(),
          Category.routeName: (context) => Category(),
          ShowProductspage.routeName: (context) => ShowProductspage(),
          ProfilePage.routeName: (context) => ProfilePage(),
          EditProfilePage.routeName: (context) => EditProfilePage(),
          Wishlist.routeName: (context) => Wishlist(),
        },
      ),
    );
  }
}
