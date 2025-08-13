import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shop/app_colors.dart';
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

  @override
  TextEditingController Emailcontroller = TextEditingController(
    text: 'ahmedrady03@gmail.com',
  );
  TextEditingController Passwordcontroller = TextEditingController(
    text: 'aA123456',
  );
  bool isobsecured = false;
  bool checkboxvalue = false;

  final authService = AuthService();
  void login() async {
    final email = Emailcontroller.text.trim();
    final password = Passwordcontroller.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      await authService.signInWithEmailAndPassword(email, password);

      sharedpref = await SharedPreferences.getInstance();

      bool token = await sharedpref!.setBool('token', true);

      log('token now $token');
      Navigator.pushReplacementNamed(context, Navigationbar.routeName);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
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
                  style: GoogleFonts.sen(fontSize: 16.sp, color: Colors.black),
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
                      value: checkboxvalue,
                      onChanged: (value) async {
                        setState(() {
                          checkboxvalue = value!;
                        });
                        SharedPreferences sahredPref =
                            await SharedPreferences.getInstance();
                        checkboxvalue == true &&
                                Emailcontroller.text.isNotEmpty &&
                                Passwordcontroller.text.isNotEmpty
                            ? sahredPref.setBool('remember', checkboxvalue)
                            : sahredPref.remove('remember');
                        sahredPref.setString('email', Emailcontroller.text);
                        sahredPref.setString(
                          'password',
                          Passwordcontroller.text,
                        );
                        log(checkboxvalue.toString());
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
                        Navigator.pushNamed(context, ForgotPassword.routeName);
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
                customButtom(
                  title: 'Log in',
                  onTap: () {
                    login();
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
                        Navigator.pushNamed(context, RegisterPage.routeName);
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
                    // signInWithGoogle();
                  },
                  child: const CircleAvatar(
                    child: FaIcon(FontAwesomeIcons.google, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 200),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
