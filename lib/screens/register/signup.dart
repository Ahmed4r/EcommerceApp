import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/widgets/custom_text_field.dart';

/// A page that provides the signup form for new users.
class RegisterPage extends StatefulWidget {
  /// The route name for navigation to the signup page.
  static const String routeName = '/signup_page';

  /// Creates a [RegisterPage].
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // State implementation here

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController rePasswordController = TextEditingController();
  bool isobsecured = false;
  bool checkboxvalue = false;
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            RichText(
              text: TextSpan(
                text: 'sign up',
                style: GoogleFonts.sen(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: 'Please sign up to get started',
                style: GoogleFonts.sen(fontSize: 16.sp, color: Colors.black),
              ),
            ),
          ],
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
                CustomTextField(
                  labelText: 'name',
                  controller: nameController,
                  icon: FontAwesomeIcons.user,
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  labelText: 'email',
                  controller: emailController,
                  icon: FontAwesomeIcons.envelope,
                ),

                SizedBox(height: 20.h),

                CustomTextField(
                  labelText: 'password',
                  controller: passwordController,
                  icon: FontAwesomeIcons.lock,
                  type: 'password',
                ),

                SizedBox(height: 20.h),
                CustomTextField(
                  controller: rePasswordController,
                  labelText: 'confirm password',
                  icon: FontAwesomeIcons.lock,
                  type: 'password',
                ),

                SizedBox(height: 20.h),

                InkWell(
                  onTap: () {
                    // registerUser();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 327.w,
                    height: 62.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.black,
                    ),
                    child: Center(
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.cairo(
                          color: Colors.white,
                          fontSize: 20.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
