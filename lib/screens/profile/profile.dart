import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/screens/orders/orders_screen.dart';
import 'package:shop/screens/profile/cubit/profile_cubit.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:shop/widgets/theme/theme_toggle_widget.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = 'profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final authservice = FirebaseAuthService();
  bool isEditMode = false;

  @override
  void initState() {
    context.read<ProfileCubit>().loadUserData();
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileInitial || state is profileLoadingState) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is profileFailureState) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile data',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProfileCubit>().loadUserData();
                    },
                    child: Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (state is profileSuccessState) {
          // Get user data from state
          nameController.text = state.name;
          emailController.text = state.email;
          phoneController.text = state.phone;

          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            extendBodyBehindAppBar: true,
            appBar: buildAppBar(context),
            body: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 10.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: double.infinity,
                          constraints: BoxConstraints(minHeight: 380.h),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 30.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.surface.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withOpacity(0.3),
                              width: 1.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).shadowColor.withOpacity(0.1),
                                blurRadius: 10.r,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 10.h),
                              SizedBox(
                                width: double.infinity,
                                child: ThemeToggleCard(
                                  title: 'Theme Preference',
                                  subtitle:
                                      'Choose between light and dark theme',
                                  padding: EdgeInsets.all(16.w),
                                ),
                              ),
                              SizedBox(height: 10.h),

                              // My Orders Section
                              CustomTextField(
                                controller: nameController,
                                labelText: 'Name',
                                icon: Icons.person,
                                enabled: isEditMode,
                              ),
                              SizedBox(height: 5.h),
                              CustomTextField(
                                controller: emailController,
                                labelText: 'Email',
                                icon: Icons.email,
                                enabled: false,
                              ),
                              SizedBox(height: 5.h),
                              CustomTextField(
                                controller: phoneController,
                                labelText: 'Phone',
                                icon: FontAwesomeIcons.phone,
                                enabled: isEditMode,
                                keyboardTypeNumber: true,
                                validator: (p0) {
                                  if (p0 == null || p0.isEmpty) {
                                    return 'Phone number is required';
                                  }
                                  if (!RegExp(r'^\d{10}$').hasMatch(p0)) {
                                    return 'Invalid phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Theme Toggle Widget
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          isEditMode = !isEditMode;
                        });

                        if (!isEditMode) {
                          context.read<ProfileCubit>().updateUserData({
                            'uid': authservice.authService.currentUser?.uid,
                            'displayName': nameController.text,
                            'email': emailController.text,
                            'phone': phoneController.text,
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Profile updated successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 220.w,
                        height: 40.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: isEditMode
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).shadowColor.withOpacity(0.1),
                              blurRadius: 10.r,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          isEditMode ? "Save Changes" : "Edit Profile",
                          style: GoogleFonts.cairo(
                            color: isEditMode
                                ? Theme.of(context).colorScheme.onSecondary
                                : Theme.of(context).colorScheme.onPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
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
        return const Center(child: Text('Something went wrong!'));
      },
    );
  }
}

PreferredSizeWidget? buildAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
    centerTitle: true,
    leading: IconButton(
      onPressed: () async {
        try {
          await context.read<ProfileCubit>().signOut();
          // Navigate to login page after successful logout
          Navigator.pushNamedAndRemoveUntil(
            context,
            LoginPage.routeName,
            (route) => false,
          );
        } catch (e) {
          log('Error while signing out: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to sign out. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      icon: FaIcon(
        FontAwesomeIcons.signOut,
        color: Theme.of(context).appBarTheme.iconTheme?.color,
        size: 18.sp,
      ),
    ),
    title: Text(
      "My Profile",
      style: GoogleFonts.cairo(
        color: Theme.of(context).appBarTheme.titleTextStyle?.color,
        fontWeight: FontWeight.bold,
      ),
    ),
    actions: [
      IconButton(
        onPressed: () {
          Navigator.pushNamed(context, LocationAccessPage.routeName);
        },
        icon: FaIcon(
          FontAwesomeIcons.locationArrow,
          color: Theme.of(
            context,
          ).appBarTheme.iconTheme?.color?.withOpacity(0.7),
          size: 20.r,
        ),
      ),
      IconButton(
        onPressed: () {
          Navigator.pushNamed(context, OrdersScreen.routeName);
        },
        icon: FaIcon(
          FontAwesomeIcons.receipt,
          color: Theme.of(
            context,
          ).appBarTheme.iconTheme?.color?.withOpacity(0.7),
          size: 20.r,
        ),
      ),
    ],
    elevation: 0,
  );
}
