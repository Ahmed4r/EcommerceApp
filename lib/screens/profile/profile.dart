import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/profile/profile_cubit.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/widgets/custom_text_field.dart';

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
            backgroundColor: AppColors.primary,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is profileFailureState) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load profile data',
                    style: TextStyle(color: Colors.red),
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
            backgroundColor: AppColors.primary,
            extendBodyBehindAppBar: true,
            appBar: buildAppBar(context),
            body: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 340.w,
                          height: 380.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1.5.w,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10.r,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 50.r,
                                    backgroundImage: AssetImage(
                                      'assets/profile.jpg',
                                    ),
                                  ),
                                ],
                              ),
                              CustomTextField(
                                controller: nameController,
                                labelText: 'Name',
                                icon: Icons.person,
                                enabled: isEditMode,
                              ),
                              CustomTextField(
                                controller: emailController,
                                labelText: 'Email',
                                icon: Icons.email,
                                enabled: false,
                              ),
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
                          color: isEditMode ? Colors.green : Colors.black,
                          borderRadius: BorderRadius.circular(20.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10.r,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          isEditMode ? "Save Changes" : "Edit Profile",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
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
    backgroundColor: AppColors.primary,
    centerTitle: true,
    leading: IconButton(
      onPressed: () async {
        try {
          context
              .read<ProfileCubit>()
              .signOut(); // No manual navigation needed - AuthWrapper handles it
        } catch (e) {
          log('error while sign out');
        }
      },
      icon: FaIcon(FontAwesomeIcons.signOut, color: Colors.black, size: 18.sp),
    ),
    title: Text(
      "My Profile",
      style: GoogleFonts.cairo(
        color: Colors.black,
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
          color: Colors.grey,
          size: 30.r,
        ),
      ),
    ],
    elevation: 0,
  );
}
