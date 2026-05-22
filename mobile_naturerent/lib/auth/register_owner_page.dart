import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'login_page.dart';
import 'services/owner_document_upload_service.dart';
import 'services/owner_registration_service.dart';
import 'widgets/auth_brand_header.dart';
import 'widgets/auth_dropdowns.dart';
import 'widgets/auth_form_fields.dart';
import 'widgets/auth_upload_field.dart';

class RegisterOwnerPage extends StatefulWidget {
  const RegisterOwnerPage({super.key});

  @override
  State<RegisterOwnerPage> createState() => _RegisterOwnerPageState();
}

class _RegisterOwnerPageState extends State<RegisterOwnerPage> {
  final _registrationService = OwnerRegistrationService();
  final _uploadService = OwnerDocumentUploadService();

  final _namaTokoC = TextEditingController();
  final _telpC = TextEditingController();
  final _jamC = TextEditingController();
  final _alamatC = TextEditingController();
  final _bankC = TextEditingController();
  final _rekC = TextEditingController();
  final _namaLengkapC = TextEditingController();
  final _emailC = TextEditingController();
  final _passC = TextEditingController();

  bool _obscure = true;
  bool _loading = false;

  List<Map<String, dynamic>> _lokasiList = [];
  int? _lokasiId;

  static const _bankOptions = [
    'BCA',
    'BRI',
    'Mandiri',
    'BNI',
    'BSI',
    'CIMB Niaga',
    'Danamon',
    'Permata',
    'BTN',
  ];

  final Map<String, OwnerUploadState> _uploads = {
    'profil': OwnerUploadState(),
    'ktp': OwnerUploadState(),
    'npwp': OwnerUploadState(),
    'tempat': OwnerUploadState(),
    'nib': OwnerUploadState(),
  };

  @override
  void initState() {
    super.initState();
    _loadLokasi();
  }

  Future<void> _loadLokasi() async {
    final data = await _registrationService.loadLokasi();
    if (!mounted) return;
    setState(() {
      _lokasiList = data;
    });
  }

  Future<void> _handleUpload(String key, String folder) async {
    final state = _uploads[key]!;
    setState(() => state.loading = true);

    try {
      final res = await _uploadService.pickAndUpload(folder, oldUrl: state.url);
      if (res != null) {
        setState(() {
          state.url = res.url;
          state.name = res.name;
          state.ext = res.ext;
        });
      }
    } catch (e) {
      final message = e.toString().contains('Gagal baca file')
          ? 'Gagal baca file'
          : 'Upload gagal: $e';
      _show(message);
    } finally {
      if (mounted) setState(() => state.loading = false);
    }
  }

  Future<void> _register() async {
    final email = _emailC.text.trim().toLowerCase();
    final pass = _passC.text.trim();
    final namaToko = _namaTokoC.text.trim();
    final nomorTelepon = _telpC.text.trim();
    final nomorRekening = _rekC.text.trim();
    final namaLengkap = _namaLengkapC.text.trim();

    if (namaToko.isEmpty ||
        nomorTelepon.isEmpty ||
        _jamC.text.trim().isEmpty ||
        _alamatC.text.trim().isEmpty ||
        _bankC.text.trim().isEmpty ||
        nomorRekening.isEmpty ||
        namaLengkap.isEmpty ||
        email.isEmpty ||
        pass.isEmpty ||
        _lokasiId == null) {
      _show('Semua field wajib diisi');
      return;
    }

    if (!_isNameValid(namaToko)) {
      _show('Nama toko hanya boleh berisi huruf dan spasi');
      return;
    }
    if (!_isNameValid(namaLengkap)) {
      _show('Nama lengkap hanya boleh berisi huruf dan spasi');
      return;
    }
    if (!_isNumberValid(nomorTelepon)) {
      _show('Nomor telepon hanya boleh berisi angka');
      return;
    }
    if (!_isNumberValid(nomorRekening)) {
      _show('Nomor rekening hanya boleh berisi angka');
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

    setState(() => _loading = true);

    try {
      final emailRegistered = await _registrationService.isEmailRegistered(
        email,
      );
      if (emailRegistered) {
        _show('Email sudah terdaftar');
        return;
      }

      await _registrationService.registerOwner(
        OwnerRegistrationPayload(
          namaToko: namaToko,
          nomorTelepon: nomorTelepon,
          lokasiId: _lokasiId!,
          jamOperasional: _jamC.text.trim(),
          alamat: _alamatC.text.trim(),
          fotoProfil: _uploads['profil']!.url,
          fotoKtp: _uploads['ktp']!.url,
          fotoNpwp: _uploads['npwp']!.url,
          fotoTempatUsaha: _uploads['tempat']!.url,
          fotoNib: _uploads['nib']!.url,
          bank: _bankC.text.trim(),
          nomorRekening: nomorRekening,
          namaLengkap: namaLengkap,
          email: email,
          password: pass,
        ),
      );

      if (!mounted) return;
      _show('Registrasi owner berhasil (menunggu verifikasi)');
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

  bool _isNumberValid(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  bool _isGmailValid(String value) {
    return RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$').hasMatch(value);
  }

  @override
  void dispose() {
    _namaTokoC.dispose();
    _telpC.dispose();
    _jamC.dispose();
    _alamatC.dispose();
    _bankC.dispose();
    _rekC.dispose();
    _namaLengkapC.dispose();
    _emailC.dispose();
    _passC.dispose();
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
                    const SizedBox(height: 24),
                    _sectionTitle('Detail toko'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      label: 'Nama Toko',
                      controller: _namaTokoC,
                      hint: 'Masukkan nama toko',
                    ),
                    AuthTextField(
                      label: 'Nomor Telepon',
                      controller: _telpC,
                      hint: 'Masukkan nomor telepon',
                      keyboardType: TextInputType.phone,
                    ),
                    AuthLocationDropdown(
                      value: _lokasiId,
                      items: _lokasiList,
                      onChanged: (v) => setState(() => _lokasiId = v),
                    ),
                    AuthTextField(
                      label: 'Jam Operasional',
                      controller: _jamC,
                      hint: 'Masukkan jam operasional',
                    ),
                    AuthTextField(
                      label: 'Alamat',
                      controller: _alamatC,
                      hint: 'Masukkan alamat toko',
                    ),
                    _uploadBlock(
                      title: 'Foto Profil Toko',
                      label: 'Upload Foto Profil',
                      state: _uploads['profil']!,
                      onPick: () => _handleUpload('profil', 'foto_profil'),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Verifikasi Dokumen'),
                    const SizedBox(height: 12),
                    _uploadBlock(
                      title: 'Foto KTP',
                      label: 'Upload Foto KTP',
                      state: _uploads['ktp']!,
                      onPick: () => _handleUpload('ktp', 'foto_ktp'),
                    ),
                    _uploadBlock(
                      title: 'Foto NPWP',
                      label: 'Upload Foto NPWP',
                      state: _uploads['npwp']!,
                      onPick: () => _handleUpload('npwp', 'foto_npwp'),
                    ),
                    _uploadBlock(
                      title: 'Foto Tempat Usaha',
                      label: 'Upload Foto Tempat Usaha',
                      state: _uploads['tempat']!,
                      onPick: () =>
                          _handleUpload('tempat', 'foto_tempat_usaha'),
                    ),
                    _uploadBlock(
                      title: 'Foto NIB',
                      label: 'Upload Foto NIB',
                      state: _uploads['nib']!,
                      onPick: () => _handleUpload('nib', 'foto_nib'),
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Detail Keuangan'),
                    const SizedBox(height: 12),
                    AuthBankDropdown(
                      value: _bankC.text,
                      options: _bankOptions,
                      onChanged: (value) =>
                          setState(() => _bankC.text = value ?? ''),
                    ),
                    AuthTextField(
                      label: 'Nomor Rekening',
                      controller: _rekC,
                      hint: 'Masukkan nomor rekening',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    _sectionTitle('Akun Rental'),
                    const SizedBox(height: 12),
                    AuthTextField(
                      label: 'Nama Lengkap',
                      controller: _namaLengkapC,
                      hint: 'Masukkan nama lengkap',
                    ),
                    AuthTextField(
                      label: 'Email',
                      controller: _emailC,
                      hint: 'Masukkan email',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    AuthPasswordField(
                      label: 'Password',
                      controller: _passC,
                      obscure: _obscure,
                      onToggle: () => setState(() => _obscure = !_obscure),
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
          'Mulai Sewakan Alatmu',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Sewakan alatmu, dukung petualangan mereka',
          style: GoogleFonts.poppins(
            fontSize: 13,
            color: const Color(0xFF7A7A7A),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF297B2D),
      ),
    );
  }

  Widget _uploadBlock({
    required String title,
    required String label,
    required OwnerUploadState state,
    required VoidCallback onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(title, style: GoogleFonts.poppins(fontSize: 13)),
        const SizedBox(height: 8),
        AuthUploadField(label: label, state: state, onPick: onPick),
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
