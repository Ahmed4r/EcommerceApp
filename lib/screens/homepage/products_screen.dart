import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/model/product_model.dart';
import 'package:shop/widgets/product_card.dart';

class ShowProductspage extends StatelessWidget {
  static String routeName = 'productsPage';
  const ShowProductspage({super.key});

  @override
  Widget build(BuildContext context) {
    final obj = ModalRoute.of(context)!.settings.arguments as List<Product>;
    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        forceMaterialTransparency: true,
        title: Text("Products"),
        backgroundColor: AppColors.primary,
      ),
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
