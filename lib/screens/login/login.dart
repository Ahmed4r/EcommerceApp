import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/admin/admin_page.dart';
import 'package:shop/screens/login/cubit/login_cubit.dart';
import 'package:shop/screens/login/cubit/login_state.dart';
import 'package:shop/screens/login/forgot_password/forgot_password.dart';
import 'package:shop/screens/register/signup.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shop/widgets/custom_button.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:shop/widgets/navigationbar.dart';

class LoginPage extends StatefulWidget {
  static const String routeName = '/login_page';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _login_pageState();
}

class _login_pageState extends State<LoginPage> {
  SharedPreferences? sharedpref;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    Emailcontroller.dispose();
    Passwordcontroller.dispose();
    super.dispose();
  }

  TextEditingController Emailcontroller = TextEditingController();
  // ahmedrady03@gmail.com
  TextEditingController Passwordcontroller = TextEditingController();
  // aA123456
  bool checkboxvalue = false;

  final authService = AuthService();

  Future<void> _nativeGoogleSignIn() async {
    try {
      /// Web Client ID that you registered with Google Cloud.
      const webClientId =
          '152853602646-rm6evrh302a4gunht8k0nqk5jpn2hbob.apps.googleusercontent.com';

      /// iOS Client ID that you registered with Google Cloud.
      const iosClientId =
          '152853602646-3jpm5kjlfparvi92gf3q0e8nagl42ups.apps.googleusercontent.com';

      // Initialize Google Sign-In with proper configuration for Supabase
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // For iOS, only use clientId
        clientId: iosClientId,
        // For web/server authentication with Supabase
        serverClientId: webClientId,
        // Request scopes needed for Supabase
        scopes: ['email', 'profile'],
      );

      // Clear any previous sign-in to ensure fresh authentication
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Google Sign-In cancelled')),
          );
        }
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No Access Token found.';
      }
      if (idToken == null) {
        throw 'No ID Token found.';
      }

      // Sign in with Supabase using Google tokens
      final supabase = Supabase.instance.client;
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (mounted) {
        // Handle successful sign-in
        final userId = supabase.auth.currentUser?.id;
        final userEmail = supabase.auth.currentUser?.email;

        if (userId != null) {
          var profile = await supabase
              .from('profiles')
              .select()
              .eq('id', userId)
              .maybeSingle();

          if (profile == null) {
            // Create profile if missing
            await supabase.from('profiles').insert({
              'id': userId,
              'email': userEmail,
              'role': 'customer', // default role
            });
            profile = {'role': 'customer'};
          }

          // Navigate based on user role
          if (profile['role'] == 'admin') {
            Navigator.pushReplacementNamed(context, AdminPage.routeName);
          } else {
            Navigator.pushReplacementNamed(context, Navigationbar.routeName);
          }
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google Sign-In successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      log('Google Sign-In error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google Sign-In failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(authService),

      child: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) async {
          if (state is LoginSuccess) {
            final supabase = Supabase.instance.client;
            final userId = supabase.auth.currentUser?.id;
            final userEmail = supabase.auth.currentUser?.email;
            if (userId == null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('User ID is null.')));
              return;
            }
            var profile = await supabase
                .from('profiles')
                .select()
                .eq('id', userId)
                .maybeSingle();

            if (profile == null) {
              // Create profile if missing
              await supabase.from('profiles').insert({
                'id': userId,
                'email': userEmail,
                'role': 'customer', // default role
              });
              profile = {'role': 'customer'};
            }

            if (profile['role'] == 'admin') {
              Navigator.pushReplacementNamed(context, AdminPage.routeName);
            } else {
              Navigator.pushReplacementNamed(context, Navigationbar.routeName);
            }
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          } else if (state is LoginPrefsLoaded) {
            Emailcontroller.text = state.email;
            Passwordcontroller.text = state.password;
          } else if (state is LoginLoading) {
            Center(child: CircularProgressIndicator());
          }
        },

        builder: (context, state) {
          final cubit = context.read<LoginCubit>();
          return Scaffold(
            backgroundColor: AppColors.primary,
            appBar: AppBar(
              forceMaterialTransparency: true,
              backgroundColor: AppColors.primary,
              title: Text(
                'login',
                style: GoogleFonts.sen(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
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
                      SizedBox(height: 40.h),
                      Text(
                        'Please sign in to your existing account',
                        style: GoogleFonts.sen(
                          fontSize: 16.sp,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomTextField(
                            controller: Emailcontroller,
                            labelText: 'Email',
                            icon: Icons.email,
                          ),
                          SizedBox(height: 0.h),
                          CustomTextField(
                            controller: Passwordcontroller,
                            labelText: 'Password',
                            icon: Icons.password,
                            obscureText: true,
                            type: 'password',
                          ),

                          SizedBox(height: 20.h),
                        ],
                      ),

                      Row(
                        children: [
                          Checkbox(
                            value: state is LoginPrefsLoaded
                                ? state.remember
                                : checkboxvalue,
                            onChanged: (value) async {
                              cubit.updateRemember(
                                value!,
                                Emailcontroller.text,
                                Passwordcontroller.text,
                              );
                            },
                          ),
                          Text(
                            "Remember me",
                            style: GoogleFonts.cairo(fontSize: 16.sp),
                          ),
                          const Spacer(),
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
                      SizedBox(height: 20.h),
                      CustomButton(
                        title: 'Log in',
                        onTap: () {
                          cubit.login(
                            Emailcontroller.text,
                            Passwordcontroller.text,
                          );
                          if (checkboxvalue == true) {
                            cubit.updateRemember(
                              checkboxvalue,
                              Emailcontroller.text,
                              Passwordcontroller.text,
                            );
                          }
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
                              color: Colors.black,
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
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.h),
                      InkWell(
                        onTap: () async {
                          await _nativeGoogleSignIn();
                        },
                        child: const CircleAvatar(
                          child: FaIcon(
                            FontAwesomeIcons.google,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      const SizedBox(height: 200),
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
