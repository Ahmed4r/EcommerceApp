import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:shop/model/product_model.dart';
import 'package:shop/widgets/product_card.dart';

class ShowProductspage extends StatelessWidget {
  static String routeName = 'productsPage';
  const ShowProductspage({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final List<Product> products = arguments is List<Product> ? arguments : [];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios),
        ),
        forceMaterialTransparency: true,
        title: Text("Products"),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: products.isEmpty
          ? Center(
              child: Text(
                'No products available',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              // physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // عدد الكروت في كل صف
                mainAxisSpacing: 10.h,
                crossAxisSpacing: 10.w,
                childAspectRatio: 3 / 4, // نسبة العرض للطول حسب شكل الكرت
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                if (index < products.length) {
                  return buildItemCard(context, products[index]);
                }
                return const SizedBox.shrink();
              },
            ),
    );
  }
}
