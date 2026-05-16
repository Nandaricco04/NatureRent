import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'owner_alat_page.dart';
import 'owner_home_page.dart';
import 'owner_laporan_page.dart';
import 'owner_pesanan_page.dart';

class OwnerMainPage extends StatefulWidget {
  const OwnerMainPage({super.key, required this.userId});

  final dynamic userId;

  @override
  State<OwnerMainPage> createState() => _OwnerMainPageState();
}

class _OwnerMainPageState extends State<OwnerMainPage> {
  final supabase = Supabase.instance.client;

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
      final user = await supabase
          .from('users')
          .select('email')
          .eq('id_user', widget.userId)
          .maybeSingle();

      final owner = await supabase
          .from('owner')
          .select('id_owner, nama_toko, foto_profil')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        _email = (user?['email'] ?? _email).toString();
        _ownerId = owner?['id_owner'];
        _storeName = (owner?['nama_toko'] ?? _storeName).toString();
        final photo = (owner?['foto_profil'] ?? '').toString();
        _photoUrl = photo.isEmpty ? null : photo;
        _loadingProfile = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            _Header(
              selectedIndex: _selectedIndex,
              tabs: _tabs,
              loadingProfile: _loadingProfile,
              storeName: _storeName,
              email: _email,
              photoUrl: _photoUrl,
              onTabSelected: (index) => setState(() => _selectedIndex = index),
            ),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  const OwnerHomePage(),
                  const OwnerPesananPage(),
                  OwnerAlatPage(ownerId: _ownerId),
                  const OwnerLaporanPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.selectedIndex,
    required this.tabs,
    required this.loadingProfile,
    required this.storeName,
    required this.email,
    required this.photoUrl,
    required this.onTabSelected,
  });

  final int selectedIndex;
  final List<String> tabs;
  final bool loadingProfile;
  final String storeName;
  final String email;
  final String? photoUrl;
  final ValueChanged<int> onTabSelected;

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 170,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 66, 16, 0),
          decoration: const BoxDecoration(
            color: _green,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          child: Text(
            'Dashboard Toko',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: 125,
          child: _StoreCard(
            loading: loadingProfile,
            storeName: storeName,
            email: email,
            photoUrl: photoUrl,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 222),
          child: Container(
            color: _background,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(tabs.length, (index) {
                  final selected = selectedIndex == index;
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == tabs.length - 1 ? 0 : 10,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => onTabSelected(index),
                      child: Container(
                        height: 34,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? _green : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _green),
                        ),
                        child: Text(
                          tabs[index],
                          style: GoogleFonts.poppins(
                            color: selected ? Colors.white : _green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({
    required this.loading,
    required this.storeName,
    required this.email,
    required this.photoUrl,
  });

  final bool loading;
  final String storeName;
  final String email;
  final String? photoUrl;

  static const _green = Color(0xFF297B2D);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFFE9F3EA),
              child: photoUrl == null
                  ? const Icon(Icons.storefront, color: _green, size: 30)
                  : Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.storefront,
                          color: _green,
                          size: 30,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: loading
                ? const LinearProgressIndicator(color: _green)
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6D6A66),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            height: 26,
            child: OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: _text,
                side: const BorderSide(color: _green),
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              child: Text(
                'Edit Profile',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
