import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shop/screens/category/category.dart';
import 'package:shop/screens/homepage/homepage.dart';
import 'package:shop/screens/profile/profile.dart';
import 'package:shop/screens/wishlist/wishlist.dart';

// ignore: library_private_types_in_public_api
final GlobalKey<_NavigationbarState> navBarKey = GlobalKey();

class Navigationbar extends StatefulWidget {
  static const String routeName = 'Navigationbar';
  const Navigationbar({super.key});

  @override
  State<Navigationbar> createState() => _NavigationbarState();
}

class _NavigationbarState extends State<Navigationbar> {
  late List<Widget> pages;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Create pages once in initState to avoid recreating them on every rebuild
    pages = [const Homepage(), Category(), WishlistPage(), ProfilePage()];
  }

  void _handleIndexChanged(int i) {
    setState(() {
      _selectedIndex = i;
    });
  }

  void changeTab(int index, List<Map<String, dynamic>> categoryData) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // Keep state of each page alive and avoid refetching on tab switch
      body: pages[_selectedIndex],

      bottomNavigationBar: CrystalNavigationBar(
        curve: Curves.bounceOut,
        currentIndex: _selectedIndex,

        unselectedItemColor: Colors.white,
        backgroundColor: Colors.black.withValues(alpha: 0.1),

        borderWidth: 2,
        outlineBorderColor: Colors.white,
        onTap: _handleIndexChanged,
        items: <CrystalNavigationBarItem>[
          // Home
          CrystalNavigationBarItem(
            icon: Icons.home,
            unselectedIcon: Icons.home,
            selectedColor: Colors.blue,
          ),

          // category
          CrystalNavigationBarItem(
            icon: Icons.category,
            unselectedIcon: Icons.category,
            selectedColor: Colors.orange,
          ),

          // wishlist
          CrystalNavigationBarItem(
            icon: Icons.favorite,
            unselectedIcon: Icons.favorite,
            selectedColor: Colors.red,
          ),

          // Profile
          CrystalNavigationBarItem(
            icon: Icons.person,
            unselectedIcon: Icons.person,
            selectedColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
