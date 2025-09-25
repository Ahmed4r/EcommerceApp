import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData icon;
  final bool obscureText;
  final String type;
  final bool enabled;
  final int? maxLines;
  final bool? keyboardTypeNumber;
  final String? Function(String?)? validator;
  final FocusNode? focusNode;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.icon,
    this.obscureText = false,
    this.type = "text",
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardTypeNumber,
    this.focusNode,
    TextInputType keyboardType = TextInputType.emailAddress,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withOpacity(0.8)
                : theme.colorScheme.surface.withOpacity(0.3),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark
                  ? theme.colorScheme.outline.withOpacity(0.5)
                  : theme.colorScheme.outline.withOpacity(0.4),
              width: 1.5.w,
            ),
          ),
          child: Row(
            children: [
              FaIcon(
                widget.icon,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
                size: 20.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: TextFormField(
                  focusNode: widget.focusNode,
                  maxLines: widget.maxLines,
                  enabled: widget.enabled,
                  controller: widget.controller,
                  validator: widget.validator,
                  keyboardType: widget.type == "text"
                      ? (widget.keyboardTypeNumber == true
                            ? TextInputType.phone
                            : TextInputType.text)
                      : TextInputType.visiblePassword,
                  obscureText: _obscureText,
                  style: GoogleFonts.cairo(color: theme.colorScheme.onSurface),
                  cursorColor: theme.colorScheme.primary,
                  decoration: InputDecoration(
                    suffixIcon: widget.type == "password"
                        ? IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                            icon: _obscureText
                                ? FaIcon(
                                    FontAwesomeIcons.eyeSlash,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  )
                                : FaIcon(
                                    FontAwesomeIcons.eye,
                                    color: theme.colorScheme.onSurface
                                        .withOpacity(0.7),
                                  ),
                          )
                        : null,
                    border: InputBorder.none,
                    labelText: widget.labelText,
                    labelStyle: GoogleFonts.cairo(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
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
