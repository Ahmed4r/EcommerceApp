import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/model/product.dart';
import 'package:shop/widgets/product_card.dart';

class ShowProductspage extends StatelessWidget {
  static String routeName = 'productsPage';
  const ShowProductspage({super.key});

  @override
  Widget build(BuildContext context) {
    final obj = ModalRoute.of(context)!.settings.arguments as List<Product>;
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: GridView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // عدد الكروت في كل صف
          mainAxisSpacing: 10.h,
          crossAxisSpacing: 10.w,
          childAspectRatio: 3 / 4, // نسبة العرض للطول حسب شكل الكرت
        ),
        itemCount: obj.length,
        itemBuilder: (context, index) {
          return buildItemCard(context, obj[index]);
        },
      ),
    );
  }
}
