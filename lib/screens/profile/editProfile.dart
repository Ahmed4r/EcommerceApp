import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EditProfilePage extends StatelessWidget {
  static const String routeName = 'editProfile';
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEDF1F4),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // الخلفية
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black12, Colors.black, Colors.grey],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // المحتوى الزجاجي
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // صورة البروفايل
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: const AssetImage('assets/profile.jpg'),
                        child: Stack(
                          children: [
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey,
                                child: const Icon(
                                  Icons.edit,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // حقول الإدخال
                      _glassTextField("Full Name"),
                      const SizedBox(height: 15),
                      _glassTextField("Email"),
                      const SizedBox(height: 15),
                      _glassTextField("Phone Number"),

                      const SizedBox(height: 25),

                      // زر الحفظ
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.white.withOpacity(0.2),
                          elevation: 0,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Save Changes",
                          style: GoogleFonts.cairo(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // حقل إدخال زجاجي
  Widget _glassTextField(String hint) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.15),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
