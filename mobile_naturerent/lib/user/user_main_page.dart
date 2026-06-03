import 'package:flutter/material.dart';

import 'user_home_page.dart';
import 'user_keranjang_page.dart';
import 'user_pesanan_page.dart';
import 'user_profile_page.dart';
import 'user_search_page.dart';

class UserMainPage extends StatefulWidget {
  const UserMainPage({
    super.key,
    this.userId,
    this.name,
    this.email,
    this.initialIndex = 0,
    this.initialCartId,
    this.openCartCheckout = false,
    this.popCartCheckoutOnBack = false,
  });

  final dynamic userId;
  final String? name;
  final String? email;
  final int initialIndex;
  final dynamic initialCartId;
  final bool openCartCheckout;
  final bool popCartCheckoutOnBack;

  @override
  State<UserMainPage> createState() => _UserMainPageState();
}

class _UserMainPageState extends State<UserMainPage> {
  late int _selectedIndex = widget.initialIndex;
  late dynamic _initialCartId = widget.initialCartId;
  late bool _openCartCheckout = widget.openCartCheckout;
  String _homeLocation = 'Malang';
  String? _searchQuery;
  String _searchLocation = 'Malang';
  dynamic _searchCategoryId;
  bool _hideBottomNavigation = false;
  int _cartCheckoutBackSignal = 0;

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      _hideBottomNavigation = false;
      _initialCartId = null;
      _openCartCheckout = false;
      if (index != 0) _searchQuery = null;
    });
  }

  void _openSearch(String query, String locationName, dynamic categoryId) {
    setState(() {
      _selectedIndex = 0;
      _hideBottomNavigation = false;
      _initialCartId = null;
      _openCartCheckout = false;
      _homeLocation = locationName;
      _searchQuery = query;
      _searchLocation = locationName;
      _searchCategoryId = categoryId;
    });
  }

  void _closeSearch() {
    setState(() {
      _searchQuery = null;
      _hideBottomNavigation = false;
      _initialCartId = null;
      _openCartCheckout = false;
    });
  }

  Future<bool> _handleBack() async {
    if (_searchQuery != null) {
      _closeSearch();
      return false;
    }

    if (_hideBottomNavigation && widget.popCartCheckoutOnBack) {
      return true;
    }

    if (_hideBottomNavigation) {
      setState(() {
        _hideBottomNavigation = false;
        _cartCheckoutBackSignal++;
      });
      return false;
    }

    if (_selectedIndex != 0) {
      _selectTab(0);
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      if (_searchQuery == null)
        UserHomePage(
          userId: widget.userId,
          name: widget.name,
          initialLocation: _homeLocation,
          onLocationChanged: (location) => _homeLocation = location,
          onOpenSearch: _openSearch,
        )
      else
        UserSearchPage(
          initialQuery: _searchQuery!,
          initialLocation: _searchLocation,
          initialCategoryId: _searchCategoryId,
          onBack: _closeSearch,
        ),
      UserKeranjangPage(
        initialSelectedCartId: _initialCartId,
        openCheckoutOnLoad: _openCartCheckout,
        popCheckoutOnBack: widget.popCartCheckoutOnBack,
        checkoutBackSignal: _cartCheckoutBackSignal,
        onCheckoutComplete: () => _selectTab(2),
        onCheckoutModeChanged: (value) {
          if (value && _initialCartId != null) {
            _initialCartId = null;
            _openCartCheckout = false;
          }
          if (_hideBottomNavigation == value) return;
          setState(() => _hideBottomNavigation = value);
        },
      ),
      UserPesananPage(onBack: () => _selectTab(0)),

      UserProfilePage(
        userId: widget.userId,
        name: widget.name,
        email: widget.email,
        onBack: () => _selectTab(0),
      ),
    ];

    return WillPopScope(
      onWillPop: _handleBack,
      child: Scaffold(
        backgroundColor: _background,
        body: pages[_selectedIndex],
        bottomNavigationBar: _searchQuery == null && !_hideBottomNavigation
            ? _bottomNavigationBar()
            : null,
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            color: selected ? _green : Colors.black87,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
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
    );
  }
}
