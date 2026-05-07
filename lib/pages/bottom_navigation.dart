//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'cart_page.dart'; // Ensure these exist
import 'profile_page.dart';
import 'order_page.dart';

import '../core/responsive.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CartPage(),
    OrderPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This ensures the body extends behind the navigation bar if you want transparency
      extendBody: true,
      backgroundColor: const Color(0xFF070A11),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: Responsive(context).bottomNavHeight(),
        margin: EdgeInsets.all(Responsive(context).s(16)), // Floating effect

        decoration: BoxDecoration(
          color: const Color(0xF20E0F13), // Slate Midnight 95% opacity
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: const Color(0x0DFFFFFF)),
          boxShadow: [
            BoxShadow(
              color: const Color(0x66444444),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: const Color(0x26FFB300),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: Color(0xFFFFB300),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  );
                }
                return const TextStyle(color: Colors.white54, fontSize: 12);
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(
                    color: Color(0xFFFFB300),
                    size: 28,
                  );
                }
                return const IconThemeData(color: Colors.white54, size: 24);
              }),
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home_rounded),
                  label: "Home",
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart_rounded),
                  label: "Cart",
                ),

                NavigationDestination(
                  icon: Icon(Icons.shopping_bag_outlined),
                  selectedIcon: Icon(Icons.shopping_bag_rounded),
                  label: "Orders",
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: "Profile",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
