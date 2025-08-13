import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  bool obscureText;
  final String type;

  CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.type = "text",
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: Colors.white.withOpacity(0.4),
              width: 1.5.w,
            ),
          ),
          child: Row(
            children: [
              FaIcon(widget.icon, color: Colors.black54, size: 20.sp),
              SizedBox(width: 10.w),
              Expanded(
                child: TextField(
                  keyboardType: widget.type == "text"
                      ? TextInputType.text
                      : TextInputType.visiblePassword,
                  controller: widget.controller,

                  obscureText: widget.obscureText,
                  style: GoogleFonts.cairo(color: Colors.black87),
                  decoration: widget.type == "text"
                      ? InputDecoration(
                          border: InputBorder.none,
                          labelText: widget.labelText,
                          labelStyle: GoogleFonts.cairo(color: Colors.black54),
                        )
                      : InputDecoration(
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.obscureText = !widget.obscureText;
                              });
                            },
                            icon: widget.obscureText
                                ? FaIcon(FontAwesomeIcons.eyeSlash)
                                : FaIcon(FontAwesomeIcons.eye),
                          ),
                          border: InputBorder.none,
                          labelText: widget.labelText,
                          labelStyle: GoogleFonts.cairo(color: Colors.black54),
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
