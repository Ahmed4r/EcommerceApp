// OTP Screen is currently not implemented
// This screen was previously used for Supabase magic link authentication
// but has been disabled in favor of Firebase Auth email/password authentication

// If phone verification is needed in the future, implement Firebase Auth phone verification here

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';

class OtpScreen extends StatefulWidget {
  static const routeName = '/otp-screen';

  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'OTP Verification',
          style: GoogleFonts.cairo(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.construction, size: 64.r, color: Colors.grey[400]),
              SizedBox(height: 16.h),
              Text(
                'OTP Verification',
                style: GoogleFonts.cairo(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'This feature is currently not implemented.\nThe app uses Firebase Auth email/password authentication.',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 16.sp,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
