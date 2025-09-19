import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/homepage/cubit/homepage.dart';
import 'package:shop/screens/homepage/cubit/homepage_cubit.dart';
import 'package:shop/screens/login/cubit/login_cubit.dart';
import 'package:shop/screens/location/address_details_Screen.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/screens/onboarding/onboarding_screen.dart';
import 'package:shop/screens/splash/welcome_screen.dart';
import 'package:shop/screens/profile/personal_info.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/wishlist.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/widgets/navigationbar.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WishlistCubit()),
        BlocProvider(create: (_) => HomepageCubit()),
        BlocProvider(create: (_) => LoginCubit(FirebaseAuthService())),
      ],
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
        home: AuthWrapper(), // Use AuthWrapper instead of initialRoute
        routes: {
          Homepage.routeName: (context) => Homepage(),
          ShowProductspage.routeName: (context) => ShowProductspage(),
          ProfilePage.routeName: (context) => ProfilePage(),
          CartScreen.routeName: (context) => CartScreen(),
          WishlistPage.routeName: (context) => WishlistPage(),
          LocationAccessPage.routeName: (context) => LocationAccessPage(),
          AddressListScreen.routeName: (context) => AddressListScreen(),
          LoginPage.routeName: (context) => LoginPage(),
          RegisterPage.routeName: (context) => RegisterPage(),
          ForgotPassword.routeName: (context) => ForgotPassword(),
          Navigationbar.routeName: (context) => Navigationbar(),
          OnboardingScreen.routeName: (context) => OnboardingScreen(),
          WelcomeScreen.routeName: (context) => const WelcomeScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return Navigationbar();
        } else {
          // User is not logged in
          return LoginPage();
        }
      },
    );
  }
}

class MyBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    log('onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log('onChange -- ${bloc.runtimeType}, $change');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log('onError -- ${bloc.runtimeType}, $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    log('onClose -- ${bloc.runtimeType}');
  }
}
