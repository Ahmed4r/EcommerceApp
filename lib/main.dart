import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/admin/add_page.dart';
import 'package:shop/screens/admin/admin_page.dart';
import 'package:shop/screens/admin/delete_page.dart';
import 'package:shop/screens/admin/edit_page.dart';
import 'package:shop/screens/cart/cart_Screen.dart';
import 'package:shop/screens/category/category.dart';
import 'package:shop/screens/homepage/cubit/homepage.dart';
import 'package:shop/screens/location/address_details_Screen.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/screens/login/otp/otp_screen.dart';
import 'package:shop/screens/onboarding/onboarding_screen.dart';
import 'package:shop/screens/profile/personal_info.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/wishlist.dart';
import 'package:shop/widgets/navigationbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lcbhbensqcotqqyywegd.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxjYmhiZW5zcWNvdHFxeXl3ZWdkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwOTc5ODQsImV4cCI6MjA3MDY3Mzk4NH0.z0_iRuwLSiCBEbwRPU620JzEr2aRgmF1FlB3q3l5R28', // الـ anon key من Settings -> API
  );
  final sharedpref = await SharedPreferences.getInstance();
  final token = sharedpref.getBool('authToken') ?? false;
  final isAdmin = sharedpref.getBool('isAdmin') ?? false;
  final onboardingSeen = sharedpref.getBool('onboarding_seen') ?? false;

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => WishlistCubit())],
      child: ShopApp(
        token: token,
        isAdmin: isAdmin,
        onboardingSeen: onboardingSeen,
      ),
    ),
  );
}

class ShopApp extends StatelessWidget {
  final bool token;
  final bool isAdmin;
  final bool onboardingSeen;
  const ShopApp({
    super.key,
    required this.token,
    required this.isAdmin,
    required this.onboardingSeen,
  });

  @override
  Widget build(BuildContext context) {
    log(token.toString());
    String initialRoute = Navigationbar.routeName;
    if (onboardingSeen == false) {
      initialRoute = OnboardingScreen.routeName;
    } else if (token == false) {
      initialRoute = LoginPage.routeName;
    } else if (isAdmin == true) {
      initialRoute = AdminPage.routeName;
    }

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: initialRoute,
        routes: {
          Homepage.routeName: (context) => Homepage(),
          AddProductPage.routeName: (context) => AddProductPage(),
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
          OnboardingScreen.routeName: (context) => OnboardingScreen(),
          DeleteProductPage.routeName: (context) =>
              DeleteProductPage(product: {}),
          EditProductPage.routeName: (context) => EditProductPage(product: {}),
          AdminPage.routeName: (context) => AdminPage(),
        },
      ),
    );
  }
}
