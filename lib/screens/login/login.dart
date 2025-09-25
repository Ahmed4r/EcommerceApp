import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/screens/login/cubit/login_cubit.dart';
import 'package:shop/screens/login/cubit/login_state.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/widgets/custom_button.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:shop/widgets/navigationbar.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login_page';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  SharedPreferences? sharedPref;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool checkboxValue = false;

  final authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginFailureState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.error)));
        } else if (state is LoginSuccessState) {
          // Navigate based on user role
          if (state.isAdmin) {
            // Navigate to admin dashboard
            // You need to create an admin dashboard route
            Navigator.pushReplacementNamed(context, '/admin_dashboard');
          } else {
            // Navigate to regular user main app
            Navigator.pushReplacementNamed(context, Navigationbar.routeName);
          }
        }
      },
      child: BlocBuilder<LoginCubit, LoginState>(
        builder: (context, state) {
          if (state is LoginLoadingState) {
            return Scaffold(
              backgroundColor: Theme.of(context).colorScheme.background,
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Default login form for all other states
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              forceMaterialTransparency: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              title: Text(
                'Login',
                style: GoogleFonts.sen(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).appBarTheme.titleTextStyle?.color,
                ),
              ),
              centerTitle: true,
            ),
            body: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30.h),
                      Text(
                        'Please sign in to your existing account',
                        style: GoogleFonts.sen(
                          fontSize: 16.sp,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextField(
                            controller: emailController,
                            labelText: 'Email',
                            icon: Icons.email,
                          ),
                          SizedBox(height: 0.h),
                          CustomTextField(
                            controller: passwordController,
                            labelText: 'Password',
                            icon: Icons.password,
                            obscureText: true,
                            type: 'password',
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),

                      SizedBox(height: 20.h),
                      CustomButton(
                        title: 'Log in',
                        onTap: () {
                          context.read<LoginCubit>().login(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                      ),

                      SizedBox(height: 20.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Don\'t have an account?',
                            style: GoogleFonts.cairo(
                              fontSize: 16.sp,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                RegisterPage.routeName,
                              );
                            },
                            child: Text(
                              'Sign up',
                              style: GoogleFonts.cairo(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Or',
                        style: GoogleFonts.cairo(
                          fontSize: 16.sp,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      InkWell(
                        onTap: () async {
                          await context.read<LoginCubit>().nativeGoogleSignIn();
                        },
                        child: const CircleAvatar(
                          child: FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          log('clicked');
                          Navigator.pushNamed(
                            context,
                            ForgotPassword.routeName,
                          );
                        },
                        child: Text(
                          'Forgot password',
                          style: GoogleFonts.cairo(
                            fontSize: 16.sp,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
