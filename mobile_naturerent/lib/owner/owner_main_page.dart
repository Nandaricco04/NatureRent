import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_page.dart';
import '../auth/session_manager.dart';
import 'owner_alat_page.dart';
import 'owner_edit_profile_page.dart';
import 'owner_home_page.dart';
import 'owner_laporan_page.dart';
import 'owner_pesanan_page.dart';
import 'services/owner_main_service.dart';
import 'widgets/owner_main_widgets.dart';

class OwnerMainPage extends StatefulWidget {
  const OwnerMainPage({super.key, required this.userId});

  final dynamic userId;

  @override
  State<OwnerMainPage> createState() => _OwnerMainPageState();
}

class _OwnerMainPageState extends State<OwnerMainPage> {
  final _mainService = OwnerMainService();

  int _selectedIndex = 0;
  bool _loadingProfile = true;
  dynamic _ownerId;
  String _storeName = 'Toko Rental';
  String _email = 'owner@gmail.com';
  String? _photoUrl;

  static const _background = Color(0xFFF5F2ED);
  final _tabs = const ['Home', 'Pesanan', 'Alat', 'Laporan'];

  @override
  void initState() {
    super.initState();
    _loadStoreProfile();
  }

  Future<void> _loadStoreProfile() async {
    try {
      final profile = await _mainService.fetchStoreProfile(widget.userId);
      if (!mounted) return;
      setState(() {
        _email = profile.email;
        _ownerId = profile.ownerId;
        _storeName = profile.storeName;
        _photoUrl = profile.photoUrl;
        _loadingProfile = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _openEditProfile() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserEditTokoProfilePage(
          userId: widget.userId,
          name: _storeName,
          email: _email,
        ),
      ),
    );

    _loadStoreProfile();
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            OwnerDashboardHeader(
              selectedIndex: _selectedIndex,
              tabs: _tabs,
              loadingProfile: _loadingProfile,
              storeName: _storeName,
              email: _email,
              photoUrl: _photoUrl,
              onTabSelected: (index) => setState(() => _selectedIndex = index),
              onEditProfile: _openEditProfile,
              onLogout: _logout,
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  OwnerHomePage(ownerId: _ownerId),
                  OwnerPesananPage(ownerId: _ownerId),
                  OwnerAlatPage(ownerId: _ownerId, userId: widget.userId),
                  OwnerLaporanPage(ownerId: _ownerId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
