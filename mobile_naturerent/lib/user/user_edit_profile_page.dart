import 'package:flutter/material.dart';

import 'services/user_profile_service.dart';
import 'widgets/user_edit_profile_widgets.dart';

class UserEditProfilePage extends StatefulWidget {
  const UserEditProfilePage({
    super.key,
    required this.userId,
    required this.name,
    required this.email,
  });

  final dynamic userId;
  final String name;
  final String email;

  @override
  State<UserEditProfilePage> createState() => _UserEditProfilePageState();
}

class _UserEditProfilePageState extends State<UserEditProfilePage> {
  final _profileService = UserProfileService();

  final _firstNameC = TextEditingController();
  final _lastNameC = TextEditingController();
  final _usernameC = TextEditingController();
  final _birthDateC = TextEditingController();
  final _phoneC = TextEditingController();
  final _emailC = TextEditingController();
  final _provinceC = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  bool _uploadingPhoto = false;
  int? _lokasiId;
  String? _profilePhotoUrl;
  List<Map<String, dynamic>> _lokasiList = [];

  static const _green = Color(0xFF297B2D);
  static const _background = Color(0xFFF5F2ED);

  @override
  void initState() {
    super.initState();
    _usernameC.text = widget.name;
    _emailC.text = widget.email;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _profileService.loadProfile(widget.userId);

      if (!mounted) return;
      setState(() {
        if (data.user != null) {
          _usernameC.text = (data.user!['nama'] ?? widget.name).toString();
          _emailC.text = (data.user!['email'] ?? widget.email).toString();
        }
        _lokasiList = data.locations;
        final profile = data.profile;
        if (profile != null) {
          _firstNameC.text = (profile['first_name'] ?? '').toString();
          _lastNameC.text = (profile['last_name'] ?? '').toString();
          _birthDateC.text = (profile['birth_date'] ?? '').toString();
          _phoneC.text = (profile['phone'] ?? '').toString();
          _provinceC.text = (profile['provinsi'] ?? '').toString();
          _profilePhotoUrl = (profile['profile_photo_url'] ?? '').toString();
          if (_profilePhotoUrl!.isEmpty) _profilePhotoUrl = null;
          _lokasiId = profile['lokasi_id'] as int?;
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show('Gagal memuat profil: $e');
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked == null) return;
    _birthDateC.text =
        '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      setState(() => _uploadingPhoto = true);

      final url = await _profileService.pickAndUploadPhoto(
        userId: widget.userId,
        oldPhotoUrl: _profilePhotoUrl,
      );
      if (url == null) return;

      if (!mounted) return;
      setState(() => _profilePhotoUrl = url);
      _show('Foto profil berhasil dipilih');
    } catch (e) {
      _show('Upload foto gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _saveProfile() async {
    final firstName = _firstNameC.text.trim();
    final lastName = _lastNameC.text.trim();
    final username = _usernameC.text.trim();
    final phone = _phoneC.text.trim();
    final province = _provinceC.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        username.isEmpty ||
        _birthDateC.text.trim().isEmpty ||
        phone.isEmpty ||
        _lokasiId == null ||
        province.isEmpty) {
      _show('Semua field wajib diisi');
      return;
    }

    if (!_isNameValid(firstName) ||
        !_isNameValid(lastName) ||
        !_isNameValid(username)) {
      _show('Nama hanya boleh berisi huruf dan spasi');
      return;
    }

    if (!_isNumberValid(phone)) {
      _show('Nomor telepon hanya boleh berisi angka');
      return;
    }

    setState(() => _saving = true);

    try {
      await _profileService.saveProfile(
        username: username,
        payload: UserProfilePayload(
          userId: widget.userId,
          lokasiId: _lokasiId!,
          firstName: firstName,
          lastName: lastName,
          birthDate: _birthDateC.text.trim(),
          phone: phone,
          province: province,
          photoUrl: _profilePhotoUrl,
        ),
      );

      if (!mounted) return;
      _show('Profil berhasil disimpan');
      Navigator.pop(context);
    } catch (e) {
      _show('Gagal menyimpan profil: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  bool _isNameValid(String value) {
    return RegExp(r'^[A-Za-z\s]+$').hasMatch(value);
  }

  bool _isNumberValid(String value) {
    return RegExp(r'^[0-9]+$').hasMatch(value);
  }

  void _show(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  void dispose() {
    _firstNameC.dispose();
    _lastNameC.dispose();
    _usernameC.dispose();
    _birthDateC.dispose();
    _phoneC.dispose();
    _emailC.dispose();
    _provinceC.dispose();
    super.dispose();
  }

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
                    EditProfileHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 20),
                    EditProfileSummary(
                      name: _usernameC.text,
                      email: _emailC.text,
                      photoUrl: _profilePhotoUrl,
                      uploading: _uploadingPhoto,
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SizedBox(
                        width: 150,
                        height: 36,
                        child: OutlinedButton(
                          onPressed:
                              _uploadingPhoto ? null : _pickAndUploadPhoto,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF212121),
                            disabledForegroundColor: const Color(0xFF212121),
                            side: const BorderSide(color: Color(0xFF212121)),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Ganti Foto Profil',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    EditProfileFormCard(
                      title: 'Informasi Pribadi',
                      children: [
                        _field('Nama Depan', _firstNameC),
                        _field('Nama Belakang', _lastNameC),
                        _field('Nama Pengguna', _usernameC),
                        _field(
                          'Tanggal Lahir',
                          _birthDateC,
                          readOnly: true,
                          suffixIcon: IconButton(
                            onPressed: _pickBirthDate,
                            icon: const Icon(Icons.calendar_month_outlined),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    EditProfileFormCard(
                      title: 'Kontak',
                      children: [
                        _field(
                          'Nomor Telepon',
                          _phoneC,
                          keyboardType: TextInputType.phone,
                        ),
                        _field('Email', _emailC, readOnly: true),
                      ],
                    ),
                    const SizedBox(height: 12),
                    EditProfileFormCard(
                      title: 'Alamat',
                      children: [
                        _lokasiDropdown(),
                        _field('Provinsi', _provinceC),
                      ],
                    ),
                    const SizedBox(height: 24),
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
                    SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _saving ? null : () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF212121),
                          side: const BorderSide(color: Color(0xFF212121)),
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

  Widget _field(
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: readOnly ? const Color(0xFFF8F8F8) : Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFD8D3CE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFD8D3CE)),
          ),
        ),
      ),
    );
  }

  Widget _lokasiDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<int>(
        value: _lokasiId,
        items: _lokasiList.map((lokasi) {
          return DropdownMenuItem<int>(
            value: lokasi['id_lokasi'] as int,
            child: Text(lokasi['nama_kota'].toString()),
          );
        }).toList(),
        onChanged: (value) => setState(() => _lokasiId = value),
        decoration: InputDecoration(
          hintText: 'Kota / Kabupaten',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFD8D3CE)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFD8D3CE)),
          ),
        ),
      ),
    );
  }
}
