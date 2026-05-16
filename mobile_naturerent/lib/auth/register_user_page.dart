import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  final supabase = Supabase.instance.client;

  Future<void> _register() async {
    final name = _nameC.text.trim();
    final email = _emailC.text.trim().toLowerCase();
    final pass = _passC.text;
    final confirm = _confirmC.text;

    if (name.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _show('Semua field wajib diisi');
      return;
    }
    if (!_isNameValid(name)) {
      _show('Nama hanya boleh berisi huruf dan spasi');
      return;
    }
    if (!_isGmailValid(email)) {
      _show('Email harus menggunakan format Gmail');
      return;
    }
    if (pass.length < 6) {
      _show('Password minimal 6 karakter');
      return;
    }
    if (pass != confirm) {
      _show('Konfirmasi password tidak sama');
      return;
    }

    setState(() => _loading = true);

    try {
      // Cek email sudah terdaftar atau belum
      final existing = await supabase
          .from('users')
          .select('email')
          .eq('email', email)
          .maybeSingle();

      if (existing != null) {
        _show('Email sudah terdaftar');
        return;
      }

      final hash = BCrypt.hashpw(pass, BCrypt.gensalt());

      await supabase.from('users').insert({
        'nama': name,
        'email': email,
        'password': hash,
        'role': 'user',
      });

      if (!mounted) return;
      _show('Registrasi berhasil');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } catch (e) {
      _show('Terjadi kesalahan: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _isNameValid(String value) {
    return RegExp(r'^[A-Za-z\s]+$').hasMatch(value);
  }

  bool _isGmailValid(String value) {
    return RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$').hasMatch(value);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _emailC.dispose();
    _passC.dispose();
    _confirmC.dispose();
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
                'Buat akun baru',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF212121),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Daftar gratis dan mulai petualanganmu',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
              const SizedBox(height: 28),

              Text('Nama Lengkap', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameC,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama lengkap',
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
                obscureText: _obscure1,
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
                    onPressed: () => setState(() => _obscure1 = !_obscure1),
                    icon: Icon(
                      _obscure1 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text(
                'Konfirmasi Password',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _confirmC,
                obscureText: _obscure2,
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
                    onPressed: () => setState(() => _obscure2 = !_obscure2),
                    icon: Icon(
                      _obscure2 ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
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
                          'Daftar',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 18),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'Sudah punya akun? ',
                    style: GoogleFonts.poppins(fontSize: 12),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                            );
                          },
                          child: Text(
                            'Masuk',
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
