import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/category/category.dart';
import 'package:shop/screens/homepage/homepage.dart';
import 'package:shop/screens/profile/personal_info.dart';
import 'package:shop/screens/wishlist/wishlist.dart';

final GlobalKey<_NavigationbarState> navBarKey = GlobalKey();

class Navigationbar extends StatefulWidget {
  static const String routeName = '/Navigationbar';
  const Navigationbar({super.key});

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  List<Widget> pages = [Homepage(), Category(), Wishlist(), ProfilePage()];
  int _selectedIndex = 0;
  void _handleIndexChanged(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  void changeTab(int index) {
    setState(() {
      _selectedIndex = index;
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
                selectedColor: Colors.orange,
              ),

              /// wishlist
              CrystalNavigationBarItem(
                icon: Icons.favorite,
                unselectedIcon: Icons.favorite,
                selectedColor: Colors.red,
              ),

              /// Profile
              CrystalNavigationBarItem(
                icon: Icons.person,
                unselectedIcon: Icons.person,
                selectedColor: Colors.black,
              ),
            ],
          ),
      // ),
    );
  }
}
