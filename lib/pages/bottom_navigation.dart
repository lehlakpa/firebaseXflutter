import 'package:flutter/material.dart';
import 'home_page.dart';
import 'cart_page.dart'; // Ensure these exist
import 'profile_page.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    CartPage(), // Replace with actual cart page
    ProfilePage(), // Replace with actual profile page
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This ensures the body extends behind the navigation bar if you want transparency
      extendBody: true,
      backgroundColor: const Color(0xFF070A11),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        height: 85,
        margin: const EdgeInsets.all(16), // Floating effect
        decoration: BoxDecoration(
          color: const Color(0xFF121721).withOpacity(0.95), // Slate Midnight
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: const Color(0xFFFFB300).withOpacity(0.15),
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
