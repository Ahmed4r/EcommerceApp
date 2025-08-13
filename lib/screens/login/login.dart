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
  SharedPreferences? sahredPref;
  @override
  void initState() {
    super.initState();
    // getPref();
  }

  // Future<void> getPref() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final email = prefs.getString('email');
  //   final password = prefs.getString('password');
  //   final remember = prefs.getBool('remember');

  //   if (remember != null && remember) {
  //     Emailcontroller.text = email ?? '';
  //     Passwordcontroller.text = password ?? '';
  //     checkboxvalue = true;
  //   }
  // }

  TextEditingController Emailcontroller = TextEditingController(text: '');
  TextEditingController Passwordcontroller = TextEditingController(text: '');
  bool isobsecured = false;
  bool checkboxvalue = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(20.r),
                //   child: BackdropFilter(
                //     filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                //     child: Container(
                //       width: 360.w,
                //       height: 200.h,
                //       decoration: BoxDecoration(
                //         color: Colors.white.withOpacity(0.2),
                //         borderRadius: BorderRadius.circular(20),
                //         border: Border.all(
                //           color: Colors.white.withOpacity(0.3),
                //           width: 1.5.w,
                //         ),
                //         boxShadow: [
                //           BoxShadow(
                //             color: Colors.black.withOpacity(0.1),
                //             blurRadius: 10.r,
                //             offset: Offset(0, 4),
                //           ),
                //         ],
                //       ),

                //       child:
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
                //     ),
                //   ),
                // ),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                    Navigator.pushNamed(context, Navigationbar.routeName);
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

  //   Future<void> _login() async {
  //     await Firebase.initializeApp(); // 👈 دي مهمة جدًا على iOS

  //     final email = Emailcontroller.text.trim();
  //     final password = Passwordcontroller.text;

  //     // Validate input
  //     if (email.isEmpty || password.isEmpty) {
  //       CustomAlert.error(context, title: 'Please enter email and password');
  //       return;
  //     }

  //     try {
  //       // Use Firebase Auth to sign in
  //       final userCredential =
  //           await FirebaseAuth.instance.signInWithEmailAndPassword(
  //         email: email,
  //         password: password,
  //       );

  //       // Fetch user role from Firestore
  //       final user = userCredential.user;
  //       if (user != null) {
  //         final userDoc = await FirebaseFirestore.instance
  //             .collection('users')
  //             .doc(user.uid)
  //             .get();
  //         if (userDoc.exists && userDoc.data() != null) {
  //           final userData = userDoc.data() as Map<String, dynamic>;
  //           final role = userData['role'] as String?;

  //           // Save credentials if "Remember me" is checked
  //           if (checkboxvalue) {
  //             await SharedPreferences.getInstance().then((prefs) {
  //               prefs.setString('email', email);
  //               prefs.setString('password', password);
  //               prefs.setBool('remember', true);
  //               prefs.setBool('authToken', true);
  //             });
  //           } else {
  //             await SharedPreferences.getInstance().then((prefs) {
  //               prefs.remove('email');
  //               prefs.remove('password');
  //               prefs.setBool('remember', false);
  //             });
  //           }

  //           // Navigate based on role
  //           if (role == 'owner') {
  //             Navigator.pushNamed(context, BottomNav.routeName);
  //           } else if (role == 'customer') {
  //             Navigator.pushNamed(context, Homepage.routeName);
  //           } else {
  //             CustomAlert.error(context, title: 'Unknown or no role found');
  //             return;
  //           }
  //         } else {
  //           CustomAlert.error(context, title: 'User data not found');
  //           return;
  //         }
  //       } else {
  //         CustomAlert.error(context, title: 'User not found');
  //         return;
  //       }

  //       CustomAlert.success(context, title: 'Successfully logged in');
  //     } on FirebaseAuthException catch (e) {
  //       CustomAlert.error(context, title: 'Error logging in: ${e.message}');
  //     } catch (e) {
  //       CustomAlert.error(context, title: 'An error occurred: $e');
  //     }
  //   }
}
