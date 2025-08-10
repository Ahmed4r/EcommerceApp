import 'package:flutter/material.dart';
import 'package:shop/widgets/navigationbar.dart';

void main() {
  runApp(const ShopApp());
}


class ShopApp extends StatelessWidget {
  const ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Navigationbar(),
    );
  }
}
