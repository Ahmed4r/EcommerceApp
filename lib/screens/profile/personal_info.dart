import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/screens/location/location_access_screen.dart';
import 'package:shop/screens/login/login.dart';
import 'package:shop/services/auth/auth_service.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = 'profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController nameController = TextEditingController();
  late TextEditingController emailController = TextEditingController();
  late TextEditingController phoneController = TextEditingController();
  String? profileImagePath;
  bool isLoading = true;
  bool updateInfo = false;
  final ImagePicker _picker = ImagePicker();

  final authservice = AuthService();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final supabase = Supabase.instance.client;

    // Load values only if controllers are empty
    if (nameController.text.isEmpty) {
      nameController.text = prefs.getString('profile_name') ?? '';
    }
    if (emailController.text.isEmpty) {
      emailController.text = supabase.auth.currentUser?.email ?? '';
    }
    if (phoneController.text.isEmpty) {
      phoneController.text = prefs.getString('profile_phone') ?? '';
    }
    if (profileImagePath == null || profileImagePath!.isEmpty) {
      profileImagePath = prefs.getString('profile_img') ?? '';
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', nameController.text);

    await prefs.setString('profile_phone', phoneController.text);
    if (profileImagePath != null) {
      await prefs.setString('profile_img', profileImagePath!);
    }
    

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Profile updated successfully!',
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickImage() async {
    if (!updateInfo) return;
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => profileImagePath = image.path);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_img', profileImagePath!);
    }
  }

  ImageProvider _getProfileImageProvider() {
    const defaultAsset = 'assets/profile.jpg';
    if (profileImagePath == null || profileImagePath!.isEmpty) {
      return const AssetImage(defaultAsset);
    }
    if (profileImagePath!.startsWith('http://') ||
        profileImagePath!.startsWith('https://')) {
      return NetworkImage(profileImagePath!);
    }
    if (File(profileImagePath!).existsSync()) {
      return FileImage(File(profileImagePath!));
    }
    return const AssetImage(defaultAsset);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        centerTitle: true,
        leading: IconButton(
          onPressed: () async {
            SharedPreferences pref = await SharedPreferences.getInstance();
            pref.remove('authToken');
            Navigator.pushReplacementNamed(context, LoginPage.routeName);
          },
          icon: FaIcon(
            FontAwesomeIcons.signOut,
            color: Colors.black,
            size: 18.sp,
          ),
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
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Center(
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
                                    backgroundImage: _getProfileImageProvider(),
                                  ),
                                  if (updateInfo)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: GestureDetector(
                                        onTap: _pickImage,
                                        child: Container(
                                          padding: EdgeInsets.all(6.r),
                                          decoration: BoxDecoration(
                                            color: Colors.blue,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 2.w,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              CustomTextField(
                                controller: nameController,
                                labelText: 'Name',
                                icon: Icons.person,
                                enabled: updateInfo,
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
                                enabled: updateInfo,
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
                        if (updateInfo) {
                          await _saveUserData();
                          FocusScope.of(context).unfocus();
                        }
                        setState(() {
                          updateInfo = !updateInfo;
                        });
                      },
                      child: Container(
                        width: 220.w,
                        height: 40.h,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: updateInfo ? Colors.green : Colors.black,
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
                          updateInfo ? "Save Changes" : "Edit Profile",
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
}
