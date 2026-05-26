import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_page.dart';
import '../auth/session_manager.dart';
import 'user_edit_profile_page.dart';
import 'user_syarat_kebijakan_page.dart';
import 'user_bantuan_dukungan_page.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    required this.userId,
    this.name,
    this.email,
    required this.onBack,
  });

  final dynamic userId;
  final String? name;
  final String? email;
  final VoidCallback onBack;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final supabase = Supabase.instance.client;
  String? _profileName;
  String? _profileEmail;
  String? _profilePhotoUrl;

  static const _green = Color(0xFF297B2D);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = await supabase
          .from('users')
          .select('nama, email')
          .eq('id_user', widget.userId)
          .maybeSingle();

      final profile = await supabase
          .from('user_profiles')
          .select('profile_photo_url')
          .eq('user_id', widget.userId)
          .maybeSingle();

      if (!mounted) return;
      setState(() {
        if (user != null) {
          final name = (user['nama'] ?? '').toString();
          final email = (user['email'] ?? '').toString();
          _profileName = name.isEmpty ? null : name;
          _profileEmail = email.isEmpty ? null : email;
        }

        if (profile != null) {
          final url = (profile['profile_photo_url'] ?? '').toString();
          _profilePhotoUrl = url.isEmpty ? null : url;
        }
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final profileName = _profileName?.trim().isNotEmpty == true
        ? _profileName!.trim()
        : widget.name?.trim().isNotEmpty == true
        ? widget.name!.trim()
        : 'Pengguna NatureRent';
    final profileEmail = _profileEmail?.trim().isNotEmpty == true
        ? _profileEmail!.trim()
        : widget.email?.trim().isNotEmpty == true
        ? widget.email!.trim()
        : 'user@gmail.com';

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            height: 122,
            color: _green,
            padding: const EdgeInsets.fromLTRB(16, 58, 16, 16),
            child: Row(
              children: [
                Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: widget.onBack,
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(Icons.arrow_back, color: _green),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Profil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          sliver: SliverList(
            delegate: SliverChildListDelegate.fixed([
              _ProfileHeader(
                name: profileName,
                email: profileEmail,
                photoUrl: _profilePhotoUrl,
              ),
              const SizedBox(height: 18),
              const _SectionTitle('Aktivitas'),
              _MenuGroup(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.calendar_month_outlined,
                    title: 'Riwayat Transaksi',
                    subtitle: 'Lihat semua riwayat sewa',
                    onTap: () {},
                  ),
                  _ProfileMenuItem(
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    subtitle: 'Pesanan, pembayaran, & pengembalian',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _SectionTitle('Akun'),
              _MenuGroup(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.person_outline,
                    title: 'Edit Profil',
                    subtitle: 'Nama, foto, & kontak',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserEditProfilePage(
                            userId: widget.userId,
                            name: profileName,
                            email: profileEmail,
                          ),
                        ),
                      ).then((_) => _loadProfileData());
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Keamanan Akun',
                    subtitle: 'Password & verifikasi',
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const _SectionTitle('Lainnya'),
              _MenuGroup(
                children: [
                  _ProfileMenuItem(
                    icon: Icons.info_outline,
                    title: 'Syarat & Kebijakan Privasi',
                    subtitle: 'Ketentuan penggunaan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UserSyaratKebijakanPage(),
                        ),
                      );
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Dukungan',
                    subtitle: 'FAQ & hubungi kami',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserBantuanDukunganPage(
                            userId: widget.userId,
                            name: profileName,
                            email: profileEmail,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _LogoutTile(
                onTap: () async {
                  await SessionManager.clearSession();
                  if (!context.mounted) return;

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ]),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.email,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          ClipOval(
            child: Container(
              width: 76,
              height: 76,
              color: const Color(0xFFE9F3EA),
              child: photoUrl == null
                  ? const Icon(Icons.person, size: 44, color: Color(0xFF297B2D))
                  : Image.network(
                      photoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) {
                        return const Icon(
                          Icons.person,
                          size: 44,
                          color: Color(0xFF297B2D),
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212121),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6D6A66),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: Color(0xFF297B2D),
        ),
      ),
    );
  }
}

class _MenuGroup extends StatelessWidget {
  const _MenuGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              const Divider(height: 1, color: Color(0xFFE5E0DB)),
          ],
        ],
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFF4F0EC),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 24, color: const Color(0xFF212121)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF6D6A66),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Color(0xFFC9C3BC), size: 24),
          ],
        ),
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFECEC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout, color: Colors.red, size: 23),
              ),
              const SizedBox(width: 14),
              const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(14),
    boxShadow: const [
      BoxShadow(color: Color(0x1A000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}
