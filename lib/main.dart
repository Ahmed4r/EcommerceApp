import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/screens/cart/cart_Screen.dart';
import 'package:shop/screens/category/category.dart';
import 'package:shop/screens/homepage/homepage.dart';
import 'package:shop/screens/location/address_details_Screen.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/screens/login/otp/otp_screen.dart';
import 'package:shop/screens/profile/personal_info.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/wishlist.dart';
import 'package:shop/widgets/navigationbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => WishlistCubit())],
      child: ShopApp(),
    ),
  );
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
        initialRoute: LoginPage.routeName,
        routes: {
          Homepage.routeName: (context) => Homepage(),
          Category.routeName: (context) => Category(),
          ShowProductspage.routeName: (context) => ShowProductspage(),
          ProfilePage.routeName: (context) => ProfilePage(),
          CartScreen.routeName: (context) => CartScreen(),
          WishlistPage.routeName: (context) => WishlistPage(),
          LocationAccessPage.routeName: (context) => LocationAccessPage(),
          AddressListScreen.routeName: (context) => AddressListScreen(),
          LoginPage.routeName: (context) => LoginPage(),
          RegisterPage.routeName: (context) => RegisterPage(),
          OtpScreen.routeName: (context) => OtpScreen(),
          ForgotPassword.routeName: (context) => ForgotPassword(),
          Navigationbar.routeName: (context) => Navigationbar(),
        },
      ),
    );
  }
}
