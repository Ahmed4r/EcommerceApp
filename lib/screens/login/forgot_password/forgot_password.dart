import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/login/otp/otp_screen.dart';
import 'package:shop/widgets/custom_button.dart';
import 'package:shop/widgets/custom_text_field.dart';

class ForgotPassword extends StatefulWidget {
  static const String routeName = '/forgot_password';
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController Emailcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: AppColors.primary,
        title: RichText(
          text: TextSpan(
            text: 'Forgot password',
            style: GoogleFonts.sen(
              fontSize: 30.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.arrow_back_ios)),

        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              SizedBox(height: 20.h),
              RichText(
                text: TextSpan(
                  text: 'Please sign in to your existing account',
                  style: GoogleFonts.sen(fontSize: 16.sp, color: Colors.black),
                ),
              ),
              SizedBox(height: 20.h),

              CustomTextField(
                controller: Emailcontroller,
                labelText: 'email',
                icon: FontAwesomeIcons.envelope,
              ),
              SizedBox(height: 20.h),
              CustomButton(
                title: 'send',
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    OtpScreen.routeName,
                    arguments: {'email': Emailcontroller.text},
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
