import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'login_page.dart';

class _UploadState {
  String? url;
  String? name;
  String? ext;
  bool loading = false;
}

class RegisterOwnerPage extends StatefulWidget {
  const RegisterOwnerPage({super.key});

  @override
  State<RegisterOwnerPage> createState() => _RegisterOwnerPageState();
}

class _RegisterOwnerPageState extends State<RegisterOwnerPage> {
  final supabase = Supabase.instance.client;

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

  final Map<String, _UploadState> _uploads = {
    'profil': _UploadState(),
    'ktp': _UploadState(),
    'npwp': _UploadState(),
    'tempat': _UploadState(),
  };

  @override
  void initState() {
    super.initState();
    _loadLokasi();
  }

  Future<void> _loadLokasi() async {
    final data = await supabase.from('lokasi').select('id_lokasi, nama_kota');
    setState(() {
      _lokasiList = List<Map<String, dynamic>>.from(data);
    });
  }

  String? _extractPathFromPublicUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final segments = uri.pathSegments;
      final bucketIndex = segments.indexOf('owner-docs');
      if (bucketIndex == -1) return null;
      return segments.sublist(bucketIndex + 1).join('/');
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, String>?> _pickAndUpload(
    String folder, {
    String? oldUrl,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final ext = (file.extension ?? '').toLowerCase();
      final fileName = file.name;
      final path = '$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';

      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes == null) {
        _show('Gagal baca file');
        return null;
      }

      String contentType;
      if (ext == 'pdf') {
        contentType = 'application/pdf';
      } else if (ext == 'jpg' || ext == 'jpeg') {
        contentType = 'image/jpeg';
      } else {
        contentType = 'image/png';
      }

      await supabase.storage.from('owner-docs').uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType),
          );

      final url = supabase.storage.from('owner-docs').getPublicUrl(path);

      if (oldUrl != null) {
        final oldPath = _extractPathFromPublicUrl(oldUrl);
        if (oldPath != null) {
          await supabase.storage.from('owner-docs').remove([oldPath]);
        }
      }

      return {'url': url, 'name': fileName, 'ext': ext};
    } catch (e) {
      _show('Upload gagal: $e');
      return null;
    }
  }

  Future<void> _handleUpload(String key, String folder) async {
    final state = _uploads[key]!;
    setState(() => state.loading = true);

    final res = await _pickAndUpload(folder, oldUrl: state.url);
    if (res != null) {
      setState(() {
        state.url = res['url'];
        state.name = res['name'];
        state.ext = res['ext'];
      });
    }

    if (mounted) setState(() => state.loading = false);
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

      final userRow = await supabase
          .from('users')
          .insert({
            'nama': namaLengkap,
            'email': email,
            'password': hash,
            'role': 'pemilikRental',
          })
          .select('id_user')
          .single();

      final userId = userRow['id_user'];

      await supabase.from('owner').insert({
        'user_id': userId,
        'nama_toko': namaToko,
        'nomor_telepon': nomorTelepon,
        'lokasi_id': _lokasiId,
        'jam_operasional': _jamC.text.trim(),
        'alamat': _alamatC.text.trim(),
        'foto_profil': _uploads['profil']!.url,
        'foto_ktp': _uploads['ktp']!.url,
        'foto_npwp': _uploads['npwp']!.url,
        'foto_tempat_usaha': _uploads['tempat']!.url,
        'bank': _bankC.text.trim(),
        'nomor_rekening': nomorRekening,
        'status_verifikasi': 'pending',
      });

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
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
              const SizedBox(height: 24),

              Text('Detail toko',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF297B2D))),
              const SizedBox(height: 12),

              _field('Nama Toko', _namaTokoC, hint: 'Masukkan nama toko'),
              _field(
                'Nomor Telepon',
                _telpC,
                hint: 'Masukkan nomor telepon',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),
              Text('Kota', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE2E2E2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: _lokasiId,
                    hint: Text('Pilih kota', style: GoogleFonts.poppins(fontSize: 13)),
                    isExpanded: true,
                    items: _lokasiList.map((e) {
                      return DropdownMenuItem<int>(
                        value: e['id_lokasi'] as int,
                        child: Text(e['nama_kota'].toString()),
                      );
                    }).toList(),
                    onChanged: (v) => setState(() => _lokasiId = v),
                  ),
                ),
              ),

              _field(
                'Jam Operasional',
                _jamC,
                hint: 'Masukkan jam operasional',
              ),
              _field('Alamat', _alamatC, hint: 'Masukkan alamat toko'),

              const SizedBox(height: 12),
              Text('Foto Profil Toko', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              _uploadField(
                label: 'Upload Foto Profil',
                state: _uploads['profil']!,
                onPick: () => _handleUpload('profil', 'foto_profil'),
              ),

              const SizedBox(height: 24),
              Text('Verifikasi Dokumen',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF297B2D))),
              const SizedBox(height: 12),

              Text('Foto KTP', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              _uploadField(
                label: 'Upload Foto KTP',
                state: _uploads['ktp']!,
                onPick: () => _handleUpload('ktp', 'foto_ktp'),
              ),

              const SizedBox(height: 12),
              Text('Foto NPWP', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              _uploadField(
                label: 'Upload Foto NPWP',
                state: _uploads['npwp']!,
                onPick: () => _handleUpload('npwp', 'foto_npwp'),
              ),

              const SizedBox(height: 12),
              Text('Foto Tempat Usaha', style: GoogleFonts.poppins(fontSize: 13)),
              const SizedBox(height: 8),
              _uploadField(
                label: 'Upload Foto Tempat Usaha',
                state: _uploads['tempat']!,
                onPick: () => _handleUpload('tempat', 'foto_tempat_usaha'),
              ),

              const SizedBox(height: 24),
              Text('Detail Keuangan',
                  style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF297B2D))),
              const SizedBox(height: 12),

              _field('Pilih Bank', _bankC, hint: 'Masukkan nama bank'),
              _field(
                'Nomor Rekening',
                _rekC,
                hint: 'Masukkan nomor rekening',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),
              Text('Akun Rental',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: const Color(0xFF297B2D))),
              const SizedBox(height: 12),

              _field(
                'Nama Lengkap',
                _namaLengkapC,
                hint: 'Masukkan nama lengkap',
              ),
              _field(
                'Email',
                _emailC,
                hint: 'Masukkan email',
                keyboardType: TextInputType.emailAddress,
              ),
              _passwordField('Password', _passC),

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

  Widget _field(
    String label,
    TextEditingController c, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: GoogleFonts.poppins(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: c,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
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
      ],
    );
  }

  Widget _passwordField(String label, TextEditingController c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(label, style: GoogleFonts.poppins(fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: c,
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
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
            ),
          ),
        ),
      ],
    );
  }

  Widget _uploadField({
    required String label,
    required _UploadState state,
    required VoidCallback onPick,
  }) {
    final isImage =
        state.ext == 'jpg' || state.ext == 'jpeg' || state.ext == 'png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: state.loading ? null : onPick,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E2E2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (state.loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.upload_file),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.loading ? 'Mengupload...' : (state.name ?? label),
                    style: GoogleFonts.poppins(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.url != null) ...[
          const SizedBox(height: 8),
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                state.url!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 18),
                const SizedBox(width: 6),
                Text(
                  state.name ?? 'Dokumen terupload',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
