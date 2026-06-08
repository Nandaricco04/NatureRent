import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bcrypt/bcrypt.dart';

import '../widgets/app_alerts.dart';

class UserKeamananAkunPage extends StatefulWidget {
  const UserKeamananAkunPage({super.key, required this.userId});

  final dynamic userId;

  @override
  State<UserKeamananAkunPage> createState() => _UserKeamananAkunPageState();
}

class _UserKeamananAkunPageState extends State<UserKeamananAkunPage> {
  final _supabase = Supabase.instance.client;

  final _passwordLamaC = TextEditingController();
  final _passwordBaruC = TextEditingController();
  final _konfirmasiC = TextEditingController();

  bool _saving = false;
  bool _obscureLama = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);
  static const _border = Color(0xFFD8D3CE);
  static const _labelColor = Color(0xFF212121);

  Future<void> _simpanPassword() async {
    final passwordLama = _passwordLamaC.text.trim();
    final passwordBaru = _passwordBaruC.text.trim();
    final konfirmasi = _konfirmasiC.text.trim();

    if (passwordLama.isEmpty || passwordBaru.isEmpty || konfirmasi.isEmpty) {
      _show('Semua field wajib diisi');
      return;
    }

    if (passwordBaru.length < 6) {
      _show('Password baru minimal 6 karakter');
      return;
    }

    if (passwordBaru != konfirmasi) {
      _show('Konfirmasi password tidak cocok');
      return;
    }

    setState(() => _saving = true);

    try {
      final user = await _supabase
          .from('users')
          .select('password')
          .eq('id_user', widget.userId)
          .maybeSingle();

      if (user == null) {
        _show('User tidak ditemukan');
        return;
      }

      final storedPassword = (user['password'] ?? '').toString();
      final cocok = BCrypt.checkpw(passwordLama, storedPassword);
      if (!cocok) {
        _show('Password lama tidak sesuai');
        return;
      }

      final hashedPassword = BCrypt.hashpw(passwordBaru, BCrypt.gensalt());
      await _supabase
          .from('users')
          .update({'password': hashedPassword})
          .eq('id_user', widget.userId);

      if (!mounted) return;
      _show('Password berhasil diperbarui');
      Navigator.pop(context);
    } catch (e) {
      _show('Gagal memperbarui password: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String msg) {
    AppAlerts.showSnackBar(
      context,
      message: msg,
      subtitle: msg == 'Password berhasil diperbarui'
          ? 'Akun kamu sekarang memakai password baru.'
          : null,
      type: _alertType(msg),
    );
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal')) return AppAlertType.error;
    return AppAlertType.warning;
  }

  @override
  void dispose() {
    _passwordLamaC.dispose();
    _passwordBaruC.dispose();
    _konfirmasiC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),
              const SizedBox(height: 8),

              const Text(
                'Buat Password yang kuat untuk menjaga akun\ndan data pribadimu tetap aman.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6D6A66),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              _buildCard(
                children: [
                  _passwordField(
                    label: 'Password',
                    hint: 'Masukkan password lama',
                    controller: _passwordLamaC,
                    obscure: _obscureLama,
                    onToggle: () =>
                        setState(() => _obscureLama = !_obscureLama),
                  ),
                  _passwordField(
                    label: 'Password Baru',
                    hint: 'Masukkan password baru',
                    controller: _passwordBaruC,
                    obscure: _obscureBaru,
                    onToggle: () =>
                        setState(() => _obscureBaru = !_obscureBaru),
                  ),
                  _passwordField(
                    label: 'Konfirmasi Password',
                    hint: 'Masukkan password baru',
                    controller: _konfirmasiC,
                    obscure: _obscureKonfirmasi,
                    onToggle: () => setState(
                      () => _obscureKonfirmasi = !_obscureKonfirmasi,
                    ),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _simpanPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    disabledBackgroundColor: _green.withOpacity(0.6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Simpan Password',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                height: 46,
                child: OutlinedButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _labelColor,
                    side: const BorderSide(color: _labelColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Batalkan',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(color: _border),
            ),
            child: const Icon(Icons.arrow_back, size: 18, color: _labelColor),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Keamanan Akun',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _labelColor,
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _passwordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 10 : 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: obscure,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: Color(0xFFAAAAAA),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: _green, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
