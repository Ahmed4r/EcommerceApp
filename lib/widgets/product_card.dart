import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/model/product.dart';
import 'package:shop/screens/homepage/details.dart';

Widget buildItemCard(BuildContext context, Product obj) {
  return GestureDetector(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailsPage(product: obj),
        ),
      );
    },
    child: Container(
      width: 150.w,
      height: 200.h,
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(obj.image), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0).r,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  obj.name,
                  style: GoogleFonts.notoSansRejang(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12.sp,
                  ),
                ),
                Flexible(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10.r, sigmaY: 10.r),
                      child: Container(
                        width: 70.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20.r),
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {},
                              child: Icon(
                                Icons.star_border_rounded,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              obj.rate.toString(),
                              style: GoogleFonts.cairo(color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // السعر + زر الإضافة للسلة
            ClipRRect(
              borderRadius: BorderRadius.circular(20.r),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 140.w,
                  height: 40.h,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                        "\$ ${obj.price.toString()}",
                        style: GoogleFonts.cairo(color: Colors.black),
                      ),
                      GestureDetector(
                        onTap: () {
                          
                        },
                        child: CircleAvatar(
                          backgroundColor: Colors.black,
                          radius: 15.r,
                          child: FaIcon(
                            FontAwesomeIcons.bagShopping,
                            color: Colors.white,
                            size: 19.r,
                          ),
                        ),
                      ),
                    ],
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
