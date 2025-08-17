import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shop/app_colors.dart';
import 'package:shop/widgets/custom_button.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteProductPage extends StatelessWidget {
  static const String routeName = '/delete-product';
  final Map product;
  final supabase = Supabase.instance.client;

  DeleteProductPage({super.key, required this.product});

  Future<void> deleteProduct(BuildContext context) async {
    await supabase.from('products').delete().eq('id', product['id']);
    Navigator.pop(context); // go back to dashboard
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Delete Product')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(
                text: 'Are you sure you want to delete ',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.secondary,
                ),
                children: [
                  TextSpan(
                    text: '"${product['name']}"?',
                    style: GoogleFonts.cairo(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 100.h),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CustomButton(
                  color: Colors.red,
                  onTap: () => deleteProduct(context),
                  title: 'Yes, Delete',
                ),
                SizedBox(height: 20.h),
                CustomButton(
                  color: Colors.transparent,
                  onTap: () => Navigator.pop(context),
                  title: 'Cancel',
                  textColor: Colors.black,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
