import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/category.dart';
import 'package:shop/screens/homepage.dart';
import 'package:shop/screens/profile.dart';
import 'package:shop/screens/wishlist.dart';

class Navigationbar extends StatefulWidget {
  const Navigationbar({super.key});

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  List<Widget> pages = [Homepage(), Category(), Wishlist(), Profile()];
  int _selectedIndex = 0;
  void _handleIndexChanged(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex], // هنا تعرض الصفحة حسب الاختيار

      bottomNavigationBar:
          //  Padding(
          //        padding: const EdgeInsets.only(bottom: 1),
          // child:
          CrystalNavigationBar(
            curve: Curves.bounceOut,
            currentIndex: _selectedIndex,
            // indicatorColor: Colors.white,
            unselectedItemColor: Colors.white,
            backgroundColor: Colors.black.withOpacity(0.1),

            borderWidth: 2,
            outlineBorderColor: Colors.white,
            onTap: _handleIndexChanged,
            items: [
              /// Home
              CrystalNavigationBarItem(
                icon: Icons.home,
                unselectedIcon: Icons.home,
                selectedColor: Colors.blue,
              ),

              /// category
              CrystalNavigationBarItem(
                icon: Icons.category,
                unselectedIcon: Icons.category,
                selectedColor: Colors.red,
              ),

              /// wishlist
              CrystalNavigationBarItem(
                icon: Icons.favorite,
                unselectedIcon: Icons.favorite,
                selectedColor: Colors.white,
              ),

              /// Profile
              CrystalNavigationBarItem(
                icon: Icons.person,
                unselectedIcon: Icons.person,
                selectedColor: Colors.white,
              ),
            ],
          ),
      // ),
    );
  }
}
