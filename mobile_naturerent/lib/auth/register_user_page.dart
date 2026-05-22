import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';
import 'services/user_registration_service.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_form_fields.dart';

class RegisterUserPage extends StatefulWidget {
  const RegisterUserPage({super.key});

  @override
  State<RegisterUserPage> createState() => _RegisterUserPageState();
}

class _RegisterUserPageState extends State<RegisterUserPage> {
  final _registrationService = UserRegistrationService();

  final _nameC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();
  final _confirmC = TextEditingController();

  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

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
      final emailRegistered = await _registrationService.isEmailRegistered(
        email,
      );
      if (emailRegistered) {
        _show('Email sudah terdaftar');
        return;
      }

      await _registrationService.registerUser(
        name: name,
        email: email,
        password: pass,
      );

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
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2ED),
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthBrandHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + keyboardInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _introText(),
                    const SizedBox(height: 28),
                    AuthTextField(
                      label: 'Nama Lengkap',
                      controller: _nameC,
                      hint: 'Masukkan nama lengkap',
                    ),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailC,
                      hint: 'email@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AuthPasswordField(
                      label: 'Password',
                      controller: _passC,
                      obscure: _obscure1,
                      onToggle: () => setState(() => _obscure1 = !_obscure1),
                    ),
                    AuthPasswordField(
                      label: 'Konfirmasi Password',
                      controller: _confirmC,
                      obscure: _obscure2,
                      onToggle: () => setState(() => _obscure2 = !_obscure2),
                    ),
                    const SizedBox(height: 24),
                    _submitButton(),
                    const SizedBox(height: 18),
                    _loginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _introText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _submitButton() {
    return SizedBox(
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
    );
  }

  Widget _loginLink() {
    return Center(
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
                    MaterialPageRoute(builder: (_) => const LoginPage()),
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
    );
  }
}
