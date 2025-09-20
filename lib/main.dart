import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/firebase_options.dart';
import 'package:shop/screens/cart/cart_screen.dart';
import 'package:shop/screens/cart/checkout_screen.dart';
import 'package:shop/screens/homepage/cubit/homepage.dart';
import 'package:shop/screens/homepage/cubit/homepage_cubit.dart';
import 'package:shop/screens/login/cubit/login_cubit.dart';
import 'package:shop/screens/location/address_details_Screen.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/screens/onboarding/onboarding_screen.dart';
import 'package:shop/screens/orders/orders_screen.dart';
import 'package:shop/screens/profile/cubit/profile_cubit.dart';
import 'package:shop/screens/register/cubit/signup_cubit.dart';
import 'package:shop/screens/splash/welcome_screen.dart';
import 'package:shop/screens/profile/profile.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/screens/wishlist/cubit/wishlist_cubit.dart';
import 'package:shop/screens/wishlist/wishlist.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/services/store/firestore_service.dart';
import 'package:shop/widgets/navigationbar.dart';
import 'package:shop/theme/theme_cubit.dart';
import 'package:shop/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  Bloc.observer = MyBlocObserver();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => WishlistCubit()),
        BlocProvider(create: (_) => HomepageCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
        BlocProvider(
          create: (_) => SignupCubit(FirebaseAuthService(), FirestoreService()),
        ),
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
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeState.themeMode,
            home: const AuthWrapper(),
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
              CheckoutScreen.routeName: (context) => CheckoutScreen(),
              '/orders': (context) => const OrdersScreen(),
            },
          );
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
        // Show loading while checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Handle errors in auth stream
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text('Authentication Error'),
                  const SizedBox(height: 8),
                  Text('${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Try to restart auth check
                      Navigator.pushReplacementNamed(
                        context,
                        LoginPage.routeName,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          // User is logged in
          return const Navigationbar();
        } else {
          // User is not logged in
          return const LoginPage();
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
