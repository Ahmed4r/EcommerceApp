import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DeleteProductPage extends StatelessWidget {
  static const String routeName = '/delete-product';
  final Map product;
  final supabase = Supabase.instance.client;

  DeleteProductPage({Key? key, required this.product}) : super(key: key);

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
            Text('Are you sure you want to delete "${product['name']}"?', textAlign: TextAlign.center),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => deleteProduct(context), child: Text('Yes, Delete'), style: ElevatedButton.styleFrom(backgroundColor: Colors.red)),
                ElevatedButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
