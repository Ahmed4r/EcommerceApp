import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product.dart';
import 'package:shop/screens/homepage/products_screen.dart';
import 'package:shop/widgets/navigationbar.dart';

class HomepageHeaders extends StatelessWidget {
  String title;
  bool ctrl;
  List<Product> products;
  List<Map<String, dynamic>> categoryData;
  HomepageHeaders(
    this.title,
    this.ctrl,
    this.products,
    this.categoryData, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.cairo(color: Colors.black, fontSize: 16.sp),
        ),
        Spacer(),
        TextButton(
          onPressed: () {
            ctrl == true
                ? navBarKey.currentState?.changeTab(1, categoryData ,)
                : Navigator.pushNamed(
                    context,
                    ShowProductspage.routeName,
                    arguments: products,
                  );
          },
          child: Text(
            "See All",
            style: GoogleFonts.cairo(color: Colors.blueAccent, fontSize: 16.sp),
          ),
        ),
        Icon(Icons.arrow_outward, color: Colors.blueAccent, size: 16.r),
      ],
    );
  }
}
