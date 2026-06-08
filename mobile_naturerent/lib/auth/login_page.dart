import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import '../user/user_main_page.dart';
import '../owner/owner_main_page.dart';
import '../widgets/app_alerts.dart';
import 'register_user_page.dart';
import 'register_owner_page.dart';
import 'session_manager.dart';

enum LoginRole { user, owner }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  bool _googleLoading = false;
  bool _handlingOAuthSession = false;
  LoginRole _selectedRole = LoginRole.user;
  StreamSubscription<AuthState>? _authSubscription;

  final supabase = Supabase.instance.client;
  static const _googleRedirectTo = 'naturerent://login-callback/';

  @override
  void initState() {
    super.initState();
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (data.event == AuthChangeEvent.signedIn && data.session != null) {
        _handleGoogleSession();
      }
    });
  }

  Future<void> _login() async {
    final email = _emailC.text.trim().toLowerCase();
    final password = _passC.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _show('Email dan password wajib diisi');
      return;
    }

    setState(() => _loading = true);

    try {
      final data = await supabase
          .from('users')
          .select('id_user, nama, email, password, role')
          .eq('email', email)
          .maybeSingle();

      if (data == null) {
        _show('Email tidak terdaftar');
        return;
      }

      final hash = data['password'] as String;
      final ok = BCrypt.checkpw(password, hash);

      if (!ok) {
        _show('Password salah');
        return;
      }

      if (!_isSelectedRoleValid(data['role'])) {
        _show(
          _selectedRole == LoginRole.user
              ? 'Akun ini bukan akun penyewa'
              : 'Akun ini bukan akun pemilik rental',
        );
        return;
      }

      await _navigateByRole(data);
    } catch (e) {
      _show('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _googleLoading = true);

    try {
      final launched = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _googleRedirectTo,
      );

      if (!launched) {
        _show('Gagal membuka login Google');
      }
    } catch (e) {
      _show('Login Google gagal: $e');
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  Future<void> _handleGoogleSession() async {
    if (_handlingOAuthSession) return;

    final authUser = supabase.auth.currentUser;
    final email = authUser?.email?.trim().toLowerCase();

    if (authUser == null || email == null || email.isEmpty) return;

    _handlingOAuthSession = true;
    if (mounted) setState(() => _googleLoading = true);

    try {
      var data = await supabase
          .from('users')
          .select('id_user, nama, email, password, role')
          .eq('email', email)
          .maybeSingle();

      if (data == null) {
        if (_selectedRole == LoginRole.owner) {
          await supabase.auth.signOut();
          _show('Akun pemilik rental harus daftar lewat form pemilik rental');
          return;
        }

        final name = _googleDisplayName(authUser, email);
        data = await supabase
            .from('users')
            .insert({
              'nama': name,
              'email': email,
              'password': BCrypt.hashpw(
                '${authUser.id}:${DateTime.now().microsecondsSinceEpoch}',
                BCrypt.gensalt(),
              ),
              'role': 'user',
            })
            .select('id_user, nama, email, password, role')
            .single();
      }

      if (!_isSelectedRoleValid(data['role'])) {
        await supabase.auth.signOut();
        _show(
          _selectedRole == LoginRole.user
              ? 'Akun Google ini bukan akun penyewa'
              : 'Akun Google ini bukan akun pemilik rental',
        );
        return;
      }

      await _navigateByRole(data, clearSupabaseAuthSession: true);
    } catch (e) {
      _show('Login Google gagal: $e');
    } finally {
      _handlingOAuthSession = false;
      if (mounted) setState(() => _googleLoading = false);
    }
  }

  String _googleDisplayName(User authUser, String email) {
    final metadata = authUser.userMetadata ?? const <String, dynamic>{};
    final name = (metadata['full_name'] ?? metadata['name'] ?? '')
        .toString()
        .trim();

    if (name.isNotEmpty) return name;
    return email.split('@').first;
  }

  bool _isSelectedRoleValid(dynamic roleValue) {
    final role = (roleValue ?? '').toString().trim().toLowerCase();

    if (_selectedRole == LoginRole.user) {
      return role == 'user';
    }

    return role == 'pemilikrental' || role == 'owner';
  }

  Future<void> _navigateByRole(
    Map<String, dynamic> data, {
    bool clearSupabaseAuthSession = false,
  }) async {
    final role = (data['role'] ?? '').toString().trim().toLowerCase();
    final userId = data['id_user'];

    if (!mounted) return;

    if (role == 'user') {
      await SessionManager.saveSession(
        userId: userId,
        role: role,
        name: data['nama']?.toString(),
        email: data['email']?.toString(),
      );

      if (clearSupabaseAuthSession) {
        await supabase.auth.signOut();
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => UserMainPage(
            userId: data['id_user'],
            name: data['nama']?.toString(),
            email: data['email']?.toString(),
          ),
        ),
        (route) => false,
      );
    } else if (role == 'pemilikrental' || role == 'owner') {
      final owner = await supabase
          .from('owner')
          .select('status_verifikasi')
          .eq('user_id', userId)
          .maybeSingle();

      if (!mounted) return;

      if (owner == null) {
        _show('Data owner untuk user ID $userId tidak ditemukan');
        return;
      }

      final status = (owner['status_verifikasi'] ?? '')
          .toString()
          .trim()
          .toLowerCase();

      if (status != 'approved') {
        _show(_ownerStatusMessage(status));
        return;
      }

      await SessionManager.saveSession(
        userId: userId,
        role: 'owner',
        name: data['nama']?.toString(),
        email: data['email']?.toString(),
      );

      if (clearSupabaseAuthSession) {
        await supabase.auth.signOut();
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => OwnerMainPage(userId: userId)),
        (route) => false,
      );
    } else {
      _show('Role akun tidak valid');
    }
  }

  void _show(String msg) {
    AppAlerts.showSnackBar(context, message: msg, type: _alertType(msg));
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal') ||
        lower.contains('kesalahan') ||
        lower.contains('salah') ||
        lower.contains('tidak')) {
      return AppAlertType.error;
    }
    return AppAlertType.warning;
  }

  String _ownerStatusMessage(String status) {
    if (status == 'inactive') {
      return 'Akun pemilik rental sedang dinonaktifkan';
    }

    if (status == 'rejected') {
      return 'Akun pemilik rental ditolak';
    }

    return 'Akun pemilik rental belum disetujui';
  }

  void _changeRole(LoginRole role) {
    if (_selectedRole == role) return;

    setState(() {
      _selectedRole = role;
      _emailC.clear();
      _passC.clear();
      _obscure = true;
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isOwner = _selectedRole == LoginRole.owner;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2ED),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _LoginHeader(isOwner: isOwner),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                decoration: const BoxDecoration(
                  color: Color(0xFFF5F2ED),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _LoginForm(
                  emailController: _emailC,
                  passwordController: _passC,
                  obscurePassword: _obscure,
                  loading: _loading,
                  googleLoading: _googleLoading,
                  selectedRole: _selectedRole,
                  onRoleChanged: _changeRole,
                  onTogglePassword: () => setState(() => _obscure = !_obscure),
                  onLogin: _loading ? null : _login,
                  onGoogleLogin: (_loading || _googleLoading)
                      ? null
                      : _loginWithGoogle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.isOwner});

  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 196,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            isOwner
                ? 'assets/images/login_pemilikrental.png'
                : 'assets/images/login_user.png',
            fit: BoxFit.cover,
            alignment: isOwner ? Alignment.center : const Alignment(0, 1),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.12),
                  Colors.black.withValues(alpha: 0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 58, 18, 20),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B8A35),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Image.asset('assets/images/Logo.png'),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Nature',
                          style: TextStyle(color: Colors.white),
                        ),
                        TextSpan(
                          text: 'Rent',
                          style: TextStyle(color: Color(0xFFFF6D1B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.loading,
    required this.googleLoading,
    required this.selectedRole,
    required this.onRoleChanged,
    required this.onTogglePassword,
    required this.onLogin,
    required this.onGoogleLogin,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final bool loading;
  final bool googleLoading;
  final LoginRole selectedRole;
  final ValueChanged<LoginRole> onRoleChanged;
  final VoidCallback onTogglePassword;
  final VoidCallback? onLogin;
  final VoidCallback? onGoogleLogin;

  @override
  Widget build(BuildContext context) {
    final isOwner = selectedRole == LoginRole.owner;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang',
          style: GoogleFonts.poppins(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          isOwner
              ? 'Kelola rental anda dengan mudah'
              : 'Masuk dan mulai sewa alat outdoor',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF6F6F6F),
          ),
        ),
        const SizedBox(height: 26),
        Row(
          children: [
            Expanded(
              child: _RoleButton(
                label: 'Penyewa (User)',
                icon: Icons.person_outline_rounded,
                selected: selectedRole == LoginRole.user,
                onTap: () => onRoleChanged(LoginRole.user),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RoleButton(
                label: 'Pemilik Rental',
                icon: Icons.storefront_outlined,
                selected: isOwner,
                onTap: () => onRoleChanged(LoginRole.owner),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text('Email', style: GoogleFonts.poppins(fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: _fieldDecoration('email@gmail.com'),
        ),
        const SizedBox(height: 16),
        Text('Password', style: GoogleFonts.poppins(fontSize: 15)),
        const SizedBox(height: 8),
        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          decoration: _fieldDecoration('Masukkan password').copyWith(
            suffixIcon: IconButton(
              onPressed: onTogglePassword,
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: const Color(0xFF6F6F6F),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          height: 44,
          child: ElevatedButton(
            onPressed: onLogin,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF287D2D),
              disabledBackgroundColor: const Color(
                0xFF287D2D,
              ).withValues(alpha: 0.65),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 0,
            ),
            child: loading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Login',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        if (!isOwner) ...[
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Atau',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF777777),
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton.icon(
              onPressed: onGoogleLogin,
              icon: Image.asset('assets/images/google.png', width: 22),
              label: googleLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF287D2D),
                      ),
                    )
                  : Text(
                      'Masuk dengan Google',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF5E5E5E),
                      ),
                    ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD8D8D8)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
        Center(
          child: Text.rich(
            TextSpan(
              text: isOwner ? 'Mau sewakan Alat? ' : 'Belum punya akun? ',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color(0xFF222222),
              ),
              children: [
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => isOwner
                              ? const RegisterOwnerPage()
                              : const RegisterUserPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Buat akun',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFFB6E21),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: const Color(0xFF656565),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFFD8D8D8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Color(0xFF287D2D), width: 1.4),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? Colors.white : const Color(0xFF222222);

    return SizedBox(
      height: 42,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 22, color: foreground),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: selected ? const Color(0xFF287D2D) : Colors.white,
          side: BorderSide(
            color: selected ? const Color(0xFF287D2D) : const Color(0xFFD8D8D8),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
      ),
    );
  }
}
