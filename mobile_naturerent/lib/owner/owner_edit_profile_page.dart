import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

// Kolom tabel owner:
// id_owner, user_id, foto_profil, nama_toko, nomor_telepon,
// lokasi_id, jam_operasional, alamat, foto_ktp, foto_npwp,
// foto_tempat_usaha, bank, nomor_rekening, status_verifikasi

class UserEditTokoProfilePage extends StatefulWidget {
  const UserEditTokoProfilePage({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  final dynamic userId;
  final String name;
  final String email;

  @override
  State<UserEditTokoProfilePage> createState() =>
      _UserEditTokoProfilePageState();
}

class _UserEditTokoProfilePageState extends State<UserEditTokoProfilePage> {
  final _supabase = Supabase.instance.client;

  // Controllers sesuai kolom tabel owner
  final _namaTokoC = TextEditingController();
  final _nomorTeleponC = TextEditingController();
  final _jamOperasionalC = TextEditingController();
  final _alamatC = TextEditingController();
  final _bankC = TextEditingController();
  final _nomorRekeningC = TextEditingController();
  final _emailC = TextEditingController();
  final _passwordC = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;
  bool _obscurePassword = true;
  int? _lokasiId;
  String? _fotoProfil;
  List<Map<String, dynamic>> _lokasiList = [];

  // Pilihan bank (kolom bank adalah VARCHAR di tabel owner)
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

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);
  static const _border = Color(0xFFD8D3CE);
  static const _labelColor = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _emailC.text = widget.email;
    _loadData();
  }

  // ── Load data owner dari Supabase ──────────────────────────────────────────
  Future<void> _loadData() async {
    try {
      // Ambil email dari tabel users
      final user = await _supabase
          .from('users')
          .select('email')
          .eq('id_user', widget.userId)
          .maybeSingle();

      // Ambil data owner berdasarkan user_id
      final owner = await _supabase
          .from('owner')
          .select(
            'nama_toko, nomor_telepon, lokasi_id, jam_operasional, '
            'alamat, bank, nomor_rekening, foto_profil',
          )
          .eq('user_id', widget.userId)
          .maybeSingle();

      // Ambil daftar lokasi dari tabel lokasi
      final lokasi = await _supabase
          .from('lokasi')
          .select('id_lokasi, nama_kota')
          .order('nama_kota');

      if (!mounted) return;
      setState(() {
        _emailC.text = (user?['email'] ?? widget.email).toString();
       _lokasiList = List<Map<String, dynamic>>.from(lokasi);

        if (owner != null) {
          _namaTokoC.text = (owner['nama_toko'] ?? '').toString();
          _nomorTeleponC.text = (owner['nomor_telepon'] ?? '').toString();
          _jamOperasionalC.text = (owner['jam_operasional'] ?? '').toString();
          _alamatC.text = (owner['alamat'] ?? '').toString();
          _bankC.text = (owner['bank'] ?? '').toString();
          _nomorRekeningC.text = (owner['nomor_rekening'] ?? '').toString();
          _lokasiId = owner['lokasi_id'] as int?;

          final foto = (owner['foto_profil'] ?? '').toString();
          _fotoProfil = foto.isEmpty ? null : foto;
        }

        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show('Gagal memuat profil: $e');
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      setState(() => _uploadingPhoto = true);

      final url = await pickAndUploadPhoto(
        userId: widget.userId,
        oldPhotoUrl: _fotoProfil,
      );

      if (url == null) return;
      if (!mounted) return;
      setState(() => _fotoProfil = url);
      _show('Foto profil berhasil diperbarui');
    } catch (e) {
      _show('Upload foto gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  // ── Upload foto profil ke Supabase Storage ─────────────────────────────────
  Future<String?> pickAndUploadPhoto({
    required dynamic userId,
    String? oldPhotoUrl,
  }) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last;
    final fileName =
        'owner_$userId\_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await Supabase.instance.client.storage
        .from(
          'foto-profil',
        ) // ganti dengan nama bucket Anda di Supabase Storage
        .uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(contentType: 'image/$ext', upsert: true),
        );

    final url = Supabase.instance.client.storage
        .from('foto-profil') // samakan dengan nama bucket di atas
        .getPublicUrl(fileName);

    return url;
  }

  // ── Simpan perubahan ke Supabase ───────────────────────────────────────────
  Future<void> _saveProfile() async {
    final namaToko = _namaTokoC.text.trim();
    final nomorTelepon = _nomorTeleponC.text.trim();
    final jamOps = _jamOperasionalC.text.trim();
    final alamat = _alamatC.text.trim();
    final bank = _bankC.text.trim();
    final nomorRekening = _nomorRekeningC.text.trim();

    if (namaToko.isEmpty ||
        nomorTelepon.isEmpty ||
        jamOps.isEmpty ||
        alamat.isEmpty ||
        bank.isEmpty ||
        nomorRekening.isEmpty ||
        _lokasiId == null) {
      _show('Semua field wajib diisi');
      return;
    }

    setState(() => _saving = true);
    try {
      // Upsert ke tabel owner — conflict key: user_id
      final result = await _supabase
          .from('owner')
          .update({
            'nama_toko': namaToko,
            'nomor_telepon': nomorTelepon,
            'lokasi_id': _lokasiId,
            'jam_operasional': jamOps,
            'alamat': alamat,
            'bank': bank,
            'nomor_rekening': nomorRekening,
            if (_fotoProfil != null) 'foto_profil': _fotoProfil,
          })
          .eq('user_id', widget.userId);

      print('Update result: $result');
      print('user_id: ${widget.userId}');

      // Update password hanya jika diisi
      final password = _passwordC.text.trim();
      if (password.isNotEmpty) {
        await _supabase.auth.updateUser(UserAttributes(password: password));
      }

      if (!mounted) return;
      _show('Profil berhasil disimpan');
      Navigator.pop(context);
    } catch (e) {
      _show('Gagal menyimpan profil: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  void dispose() {
    _namaTokoC.dispose();
    _nomorTeleponC.dispose();
    _jamOperasionalC.dispose();
    _alamatC.dispose();
    _bankC.dispose();
    _nomorRekeningC.dispose();
    _emailC.dispose();
    _passwordC.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildAvatarSection(),
                    const SizedBox(height: 12),

                    // Tombol ganti foto profil
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 36,
                        child: OutlinedButton(
                          onPressed: _uploadingPhoto
                              ? null
                              : _pickAndUploadPhoto,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _labelColor,
                            side: const BorderSide(color: _labelColor),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: _uploadingPhoto
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: _labelColor,
                                  ),
                                )
                              : const Text(
                                  'Ganti Foto Profil',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Kartu Detail Toko ──────────────────────────────────
                    _buildCard(
                      title: 'Detail Toko',
                      children: [
                        _field('Nama Toko', _namaTokoC),
                        _field(
                          'Nomor Telepon',
                          _nomorTeleponC,
                          keyboardType: TextInputType.phone,
                        ),
                        _lokasiDropdown(),
                        _field('Jam Operasional', _jamOperasionalC),
                        _field('Alamat', _alamatC, maxLines: 2),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Kartu Detail Keuangan ──────────────────────────────
                    _buildCard(
                      title: 'Detail Keuangan',
                      children: [
                        _bankDropdown(),
                        _field(
                          'Nomor Rekening',
                          _nomorRekeningC,
                          keyboardType: TextInputType.number,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Kartu Akun Rental ──────────────────────────────────
                    _buildCard(
                      title: 'Akun Rental',
                      children: [
                        _field('Email', _emailC, readOnly: true),
                        _passwordField(),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Tombol Simpan Perubahan
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _saveProfile,
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
                                'Simpan Perubahan',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tombol Batalkan
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _saving
                            ? null
                            : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _labelColor,
                          side: const BorderSide(color: _labelColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Batalkan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: _border),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: _labelColor,
                ),
              ),
            ),
          ),
          const Text(
            'Edit Profil Toko',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: _labelColor,
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar + nama + email ──────────────────────────────────────────────────
  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE9F3EA),
              backgroundImage: _fotoProfil != null
                  ? NetworkImage(_fotoProfil!)
                  : null,
              child: _fotoProfil == null
                  ? const Icon(Icons.storefront, size: 40, color: _green)
                  : null,
            ),
            if (_uploadingPhoto)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          _namaTokoC.text.isNotEmpty ? _namaTokoC.text : widget.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          _emailC.text.isNotEmpty ? _emailC.text : widget.email,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
        ),
      ],
    );
  }

  // ── Card wrapper ───────────────────────────────────────────────────────────
  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border.withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _green,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  // ── TextField generik ──────────────────────────────────────────────────────
  Widget _field(
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: readOnly ? const Color(0xFFF8F8F8) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
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
    );
  }

  // ── Password field dengan toggle visibility ────────────────────────────────
  Widget _passwordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: _passwordC,
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          hintText: 'Password baru (kosongkan jika tidak diubah)',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
          suffixIcon: IconButton(
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            icon: Icon(
              _obscurePassword
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
    );
  }

  // ── Dropdown Lokasi — dari tabel lokasi ────────────────────────────────────
  Widget _lokasiDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<int>(
        value: _lokasiId,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF7A7A7A),
        ),
        items: _lokasiList.map((item) {
          return DropdownMenuItem<int>(
            value: item['id_lokasi'] as int,
            child: Text(
              item['nama_kota'].toString(),
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: (val) => setState(() => _lokasiId = val),
        decoration: InputDecoration(
          hintText: 'Kota / Kabupaten',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
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
    );
  }

  // ── Dropdown Bank — kolom bank VARCHAR di tabel owner ──────────────────────
  Widget _bankDropdown() {
    final currentValue = _bankOptions.contains(_bankC.text)
        ? _bankC.text
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: currentValue,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF7A7A7A),
        ),
        items: _bankOptions.map((bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(bank, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: (val) => setState(() => _bankC.text = val ?? ''),
        decoration: InputDecoration(
          hintText: 'Pilih Bank',
          hintStyle: const TextStyle(fontSize: 13, color: Color(0xFFAAAAAA)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
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
    );
  }
}
