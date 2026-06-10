import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../auth/login_page.dart';
import '../auth/session_manager.dart';
import 'user_edit_profile_page.dart';
import 'user_syarat_kebijakan_page.dart';
import 'user_bantuan_dukungan_page.dart';
import 'user_keamanan_akun_page.dart';
import 'user_notification_page.dart';
import 'services/user_notification_service.dart';
import 'widgets/user_notification_widgets.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({
    super.key,
    required this.userId,
    this.name,
    this.email,
    required this.onBack,
    this.onNameChanged,
  });

  final dynamic userId;
  final String? name;
  final String? email;
  final VoidCallback onBack;
  final ValueChanged<String>? onNameChanged;

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final supabase = Supabase.instance.client;
  final _notificationService = UserNotificationService();
  String? _profileName;
  String? _profileEmail;
  String? _profilePhotoUrl;
  bool _hasUnreadNotifications = false;

  static const _green = Color(0xFF297B2D);

  @override
  void initState() {
    super.initState();
    _loadProfileData();
    _loadUnreadNotifications();
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

  Future<void> _loadUnreadNotifications() async {
    try {
      final hasUnread = await _notificationService.hasUnread(widget.userId);
      if (!mounted) return;
      setState(() => _hasUnreadNotifications = hasUnread);
    } catch (_) {}
  }

  Future<void> _openNotifications() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => UserNotificationPage(userId: widget.userId),
      ),
    );
    if (mounted) _loadUnreadNotifications();
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Keluar dari akun?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            'Kamu perlu login lagi untuk menggunakan akun ini.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Batal', style: TextStyle(color: _green)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await SessionManager.clearSession();
    await supabase.auth.signOut();
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
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
                    icon: Icons.notifications_none,
                    title: 'Notifikasi',
                    subtitle: 'Pesanan, pembayaran, & pengembalian',
                    hasBadge: _hasUnreadNotifications,
                    onTap: _openNotifications,
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
                      ).then((result) {
                        if (result is String && result.trim().isNotEmpty) {
                          final newName = result.trim();
                          setState(() => _profileName = newName);
                          widget.onNameChanged?.call(newName);
                        }
                        _loadProfileData();
                      });
                    },
                  ),
                  _ProfileMenuItem(
                    icon: Icons.lock_outline,
                    title: 'Keamanan Akun',
                    subtitle: 'Password & verifikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              UserKeamananAkunPage(userId: widget.userId),
                        ),
                      );
                    },
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
              _LogoutTile(onTap: _confirmLogout),
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
    this.hasBadge = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool hasBadge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
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
                if (hasBadge)
                  Positioned(
                    top: 1,
                    right: 1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: const BoxDecoration(
                        color: userNotificationOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
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
