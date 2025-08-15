import 'package:flutter/material.dart';
import 'package:shop/widgets/custom_button.dart';
import 'package:shop/widgets/custom_text_field.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductPage extends StatefulWidget {
  static const String routeName = '/edit-product';
  final Map product;
  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final supabase = Supabase.instance.client;
  late TextEditingController nameController;
  late TextEditingController priceController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name']);
    priceController = TextEditingController(
      text: widget.product['price'].toString(),
    );
  }

  Future<void> updateProduct() async {
    await supabase
        .from('products')
        .update({
          'name': nameController.text,
          'price': double.tryParse(priceController.text) ?? 0,
        })
        .eq('id', widget.product['id']);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CustomTextField(
              controller: nameController,
              labelText: 'Name',
              icon: Icons.person,
            ),
            CustomTextField(
              controller: priceController,
              labelText: 'Price',
              icon: Icons.price_change,
              keyboardType: TextInputType.number,
            ),

            SizedBox(height: 20),
            CustomButton(title: 'Update Product', onTap: updateProduct),
          ],
        ),
      ),
    );
  }
}
