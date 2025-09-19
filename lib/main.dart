import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/screens/admin/add_page.dart';
import 'package:shop/screens/admin/admin_page.dart';
import 'package:shop/screens/admin/orders_admin_page.dart';
import 'package:shop/screens/admin/delete_page.dart';
import 'package:shop/screens/admin/edit_page.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/cart/checkout_screen.dart';
import 'package:shop/screens/category/category.dart';
import 'package:shop/screens/homepage/cubit/homepage.dart';
import 'package:shop/screens/orders/orders_page.dart';
import 'package:shop/screens/location/address_details_Screen.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/screens/login/otp/otp_screen.dart';
import 'package:shop/screens/onboarding/onboarding_screen.dart';
import 'package:shop/screens/splash/welcome_screen.dart';
import 'package:shop/screens/profile/personal_info.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/wishlist.dart';
import 'package:shop/widgets/navigationbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiBlocProvider(
      providers: [BlocProvider(create: (_) => WishlistCubit())],
      child: ShopApp(
      
      ),
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
        initialRoute: LoginPage.routeName,
        routes: {
          OrderDetailsPage.routeName: (context) => const OrderDetailsPage(),
          Homepage.routeName: (context) => Homepage(),
          AddProductPage.routeName: (context) => AddProductPage(),
          Category.routeName: (context) => Category(),
          ShowProductspage.routeName: (context) => ShowProductspage(),
          ProfilePage.routeName: (context) => ProfilePage(),
          CartScreen.routeName: (context) => CartScreen(),
          CheckoutScreen.routeName: (context) => CheckoutScreen(),
          WishlistPage.routeName: (context) => WishlistPage(),
          LocationAccessPage.routeName: (context) => LocationAccessPage(),
          AddressListScreen.routeName: (context) => AddressListScreen(),
          LoginPage.routeName: (context) => LoginPage(),
          RegisterPage.routeName: (context) => RegisterPage(),
          OtpScreen.routeName: (context) => OtpScreen(),
          ForgotPassword.routeName: (context) => ForgotPassword(),
          Navigationbar.routeName: (context) => Navigationbar(),
          OnboardingScreen.routeName: (context) => OnboardingScreen(),
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
          DeleteProductPage.routeName: (context) =>
              DeleteProductPage(product: {}),
          EditProductPage.routeName: (context) => EditProductPage(product: {}),
          AdminPage.routeName: (context) => AdminPage(),
          OrdersAdminPage.routeName: (context) => const OrdersAdminPage(),
          OrdersPage.routeName: (context) => const OrdersPage(),
        },
      ),
    );
  }
}
