import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Function()? onTap;
  Color color;
  Color textColor;
  CustomButton({
    super.key,
    required this.title,
    this.onTap,
    this.color = Colors.black,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 327.w,
        height: 62.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.cairo(color: textColor, fontSize: 20.sp),
          ),
        ),
      ),
    );
  }
}
