import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final Color? color;
  final Color? textColor;
  const CustomButton({
    super.key,
    required this.title,
    this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final buttonColor = color ?? theme.colorScheme.primary;
    final buttonTextColor = textColor ?? theme.colorScheme.onPrimary;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: 327.w,
        height: 62.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: buttonColor,
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.cairo(color: buttonTextColor, fontSize: 20.sp),
          ),
        ),
      ),
    );
  }
}
