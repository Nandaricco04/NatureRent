import 'package:flutter/material.dart';

import 'user_home_page.dart';
import 'user_keranjang_page.dart';
import 'user_pesanan_page.dart';
import 'user_profile_page.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({
    super.key,
    this.userId,
    this.name,
    this.email,
  });

  final dynamic userId;
  final String? name;
  final String? email;

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  int _selectedIndex = 0;

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);

  void _selectTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const UserHomePage(),
      const UserKeranjangPage(),
      const UserPesananPage(),
      UserProfilePage(
        userId: widget.userId,
        name: widget.name,
        email: widget.email,
        onBack: () => _selectTab(0),
      ),
    ];

    return Scaffold(
      backgroundColor: _background,
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Colors.transparent,
          labelTextStyle: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? _green : Colors.black87,
            );
          }),
          iconTheme: MaterialStateProperty.resolveWith((states) {
            final selected = states.contains(MaterialState.selected);
            return IconThemeData(
              color: selected ? _green : Colors.black87,
              size: 25,
            );
          }),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          height: 64,
          onDestinationSelected: _selectTab,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Keranjang',
            ),
            NavigationDestination(
              icon: Icon(Icons.assignment_outlined),
              selectedIcon: Icon(Icons.assignment),
              label: 'Pesanan',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
