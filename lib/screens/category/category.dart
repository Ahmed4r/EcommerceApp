import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class Category extends StatelessWidget {
  static const String routeName = 'category';
  const Category({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffEDF1F4),
      appBar: AppBar(
        backgroundColor: Color(0xffEDF1F4),
        leading: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1.w),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
              size: 20.r,
            ),
          ),
        ),
      ),
    );
  }
}
