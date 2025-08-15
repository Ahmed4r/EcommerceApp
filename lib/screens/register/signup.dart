import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:shop/widgets/navigationbar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterPage extends StatefulWidget {
  static const String routeName = '/signup_page';

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController rePasswordController = TextEditingController();

  bool isObscured = true;
  bool checkboxValue = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    rePasswordController.dispose();
    super.dispose();
  }

  final authService = AuthService();
  void register() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    try {
      await authService.signUpWithEmailAndPassword(email, password);
      if (mounted) {
        Navigator.pushReplacementNamed(context, Navigationbar.routeName);
      }
    } catch (e) {
      if (e is AuthException) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Sign Up',
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
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Please sign up to get started',
                style: GoogleFonts.sen(fontSize: 16.sp, color: Colors.black),
              ),
              SizedBox(height: 20.h),
              Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      labelText: 'Name',
                      controller: nameController,
                      icon: FontAwesomeIcons.user,
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      labelText: 'Email',
                      controller: emailController,
                      icon: FontAwesomeIcons.envelope,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) return 'Invalid email format';
                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      controller: passwordController,
                      labelText: 'Password',
                      icon: FontAwesomeIcons.lock,
                      type: 'password',
                      obscureText: true,
                      validator: (password) {
                        if (password == null || password.isEmpty) {
                          return 'Password is required';
                        }
                        if (password.length < 8) {
                          return 'Password must be at least 8 characters';
                        }
                        if (!password.contains(RegExp(r'[A-Z]'))) {
                          return 'Password must contain at least one uppercase letter';
                        }
                        if (!password.contains(RegExp(r'[a-z]'))) {
                          return 'Password must contain at least one lowercase letter';
                        }
                        if (!password.contains(RegExp(r'[0-9]'))) {
                          return 'Password must contain at least one number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10.h),
                    CustomTextField(
                      controller: rePasswordController,
                      labelText: 'Confirm Password',
                      icon: FontAwesomeIcons.lock,
                      type: 'password',
                      obscureText: true,
                      validator: (rePassword) {
                        if (rePassword == null || rePassword.isEmpty) {
                          return 'Confirm Password is required';
                        }
                        if (rePassword != passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    register();
                  }
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
    );
  }
}
