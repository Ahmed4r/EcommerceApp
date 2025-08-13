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
import 'package:shop/widgets/custom_text_field.dart';

class ProfilePage extends StatefulWidget {
  static const String routeName = 'profile';
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  bool updateInfo = false;
  String? profileImagePath;
  final ImagePicker _picker = ImagePicker();

  // SharedPreferences keys
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _phoneKey = 'user_phone';
  static const String _imageKey = 'user_image';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // Load user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      nameController.text = prefs.getString(_nameKey) ?? '';
      emailController.text = prefs.getString(_emailKey) ?? '';
      phoneController.text = prefs.getString(_phoneKey) ?? '';
      profileImagePath = prefs.getString(_imageKey);
    });
  }

  // Save user data to SharedPreferences
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, nameController.text);
    await prefs.setString(_emailKey, emailController.text);
    await prefs.setString(_phoneKey, phoneController.text);
    if (profileImagePath != null) {
      await prefs.setString(_imageKey, profileImagePath!);
    }

    // Show success message
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

  // Pick image from gallery or camera
  Future<void> _pickImage() async {
    if (!updateInfo) return; // Only allow picking when in edit mode

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50.w,
                      height: 5.h,
                      margin: EdgeInsets.only(top: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Select Profile Picture',
                      style: GoogleFonts.cairo(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildImageSourceOption(
                          icon: Icons.camera_alt,
                          label: 'Camera',
                          source: ImageSource.camera,
                        ),
                        _buildImageSourceOption(
                          icon: Icons.photo_library,
                          label: 'Gallery',
                          source: ImageSource.gallery,
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required ImageSource source,
  }) {
    return GestureDetector(
      onTap: () async {
        Navigator.pop(context);
        final XFile? image = await _picker.pickImage(source: source);
        if (image != null) {
          setState(() {
            profileImagePath = image.path;
          });
        }
      },
      child: Column(
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.r),
              border: Border.all(
                color: Colors.blue.withOpacity(0.3),
                width: 1.5.w,
              ),
            ),
            child: Icon(icon, color: Colors.blue, size: 30.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: GoogleFonts.cairo(fontSize: 14.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
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
                    height: 380.h, // Increased height slightly
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
                        // Profile Image with edit functionality
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 50.r,
                              backgroundImage: profileImagePath != null
                                  ?
                                    //  ResizeImage(
                                    //     height: (50.h).toInt(),
                                    //     width: (50.w).toInt(),
                                    FileImage(File(profileImagePath!))
                                  // )
                                  //  ResizeImage(
                                  : AssetImage('assets/profile.jpg')
                                        // width: (50.w).toInt(),
                                        // height: (50.h).toInt(),
                                        // )
                                        as ImageProvider,
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

                        // Name Field
                        CustomTextField(
                          controller: nameController,
                          labelText: 'Name',
                          icon: Icons.person,
                        ),

                        // Email Field
                        CustomTextField(
                          controller: emailController,
                          labelText: 'Email',
                          icon: Icons.email,
                        ),

                        // Phone Field
                        CustomTextField(
                          controller: phoneController,
                          labelText: 'Phone',
                          icon: FontAwesomeIcons.phone,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Save Button
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
                  margin: EdgeInsets.only(top: 20.h),
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
