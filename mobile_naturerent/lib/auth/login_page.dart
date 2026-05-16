import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';
import '../user/user_main_page.dart';
import '../owner/owner_main_page.dart';
import 'register_user_page.dart';
import 'register_owner_page.dart';

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

  final supabase = Supabase.instance.client;

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

      await _navigateByRole(data);
    } catch (e) {
      _show('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _navigateByRole(Map<String, dynamic> data) async {
    final role = (data['role'] ?? '').toString().trim().toLowerCase();
    final userId = data['id_user'];

    if (!mounted) return;

    if (role == 'user') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => UserMainPage(
            userId: data['id_user'],
            name: data['nama']?.toString(),
            email: data['email']?.toString(),
          ),
        ),
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
        _show('Akun pemilik rental belum disetujui');
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => OwnerMainPage(userId: userId)),
      );
    } else {
      _show('Role akun tidak valid');
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _emailC.dispose();
    _passC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2ED),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/Logo.png', width: 36, height: 36),
                  const SizedBox(width: 10),
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                      children: const [
                        TextSpan(
                          text: 'Nature',
                          style: TextStyle(color: Color(0xFF297B2D)),
                        ),
                        TextSpan(
                          text: 'Rent',
                          style: TextStyle(color: Color(0xFFFB8C00)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Selamat Datang',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Masuk dan mulai sewa alat outdoor',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
              const SizedBox(height: 28),

              Text('Email', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailC,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'email@gmail.com',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text('Password', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _passC,
                obscureText: _obscure,
                decoration: InputDecoration(
                  hintText: 'Masukkan password',
                  hintStyle: GoogleFonts.poppins(fontSize: 13),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _obscure = !_obscure),
                    icon: Icon(
                      _obscure ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF297B2D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
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
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Atau',
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: Image.asset('assets/images/google.png', width: 20),
                  label: Text(
                    'Masuk dengan Google',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFE2E2E2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 18),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Belum punya akun? ',
                    style: GoogleFonts.poppins(fontSize: 12),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterUserPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Buat akun',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFB8C00),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Mau sewakan Alat? ',
                    style: GoogleFonts.poppins(fontSize: 12),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterOwnerPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Buat akun',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: const Color(0xFFFB8C00),
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
          ),
        ),
      ),
    );
  }
}
