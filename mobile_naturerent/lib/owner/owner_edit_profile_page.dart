import 'package:flutter/material.dart';

import '../widgets/app_alerts.dart';
import 'services/owner_profile_service.dart';
import 'widgets/owner_profile_form_widgets.dart';

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
  final _profileService = OwnerProfileService();

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
  String? _oldFotoProfil;
  List<Map<String, dynamic>> _lokasiList = [];

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

  @override
  void initState() {
    super.initState();
    _emailC.text = widget.email;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final data = await _profileService.fetchProfile(
        userId: widget.userId,
        fallbackEmail: widget.email,
      );

      if (!mounted) return;
      setState(() {
        _emailC.text = data.email;
        _namaTokoC.text = data.namaToko;
        _nomorTeleponC.text = data.nomorTelepon;
        _jamOperasionalC.text = data.jamOperasional;
        _alamatC.text = data.alamat;
        _bankC.text = data.bank;
        _nomorRekeningC.text = data.nomorRekening;
        _lokasiId = data.lokasiId;
        _fotoProfil = data.fotoProfil;
        _oldFotoProfil = data.fotoProfil;
        _lokasiList = data.lokasiList;
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

      final url = await _profileService.pickAndUploadPhoto(
        userId: widget.userId,
      );

      if (url == null || !mounted) return;
      final previousPhotoUrl = _fotoProfil;
      setState(() => _fotoProfil = url);
      if (previousPhotoUrl != null && previousPhotoUrl != _oldFotoProfil) {
        await _profileService.removePhoto(previousPhotoUrl);
      }
      _show('Foto profil berhasil diperbarui');
    } catch (e) {
      _show('Upload foto gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

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
      await _profileService.updateProfile(
        userId: widget.userId,
        profile: OwnerProfileUpdate(
          namaToko: namaToko,
          nomorTelepon: nomorTelepon,
          lokasiId: _lokasiId!,
          jamOperasional: jamOps,
          alamat: alamat,
          bank: bank,
          nomorRekening: nomorRekening,
          fotoProfil: _fotoProfil,
        ),
      );

      final password = _passwordC.text.trim();
      if (password.isNotEmpty) {
        await _profileService.updatePassword(password);
      }

      if (_oldFotoProfil != null && _oldFotoProfil != _fotoProfil) {
        await _profileService.removePhoto(_oldFotoProfil);
        _oldFotoProfil = _fotoProfil;
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
    AppAlerts.showSnackBar(
      context,
      message: _alertTitle(msg),
      subtitle: _alertSubtitle(msg),
      type: _alertType(msg),
    );
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal')) return AppAlertType.error;
    return AppAlertType.warning;
  }

  String _alertTitle(String message) {
    if (message == 'Profil berhasil disimpan') {
      return 'Profil toko berhasil disimpan';
    }
    if (message == 'Foto profil berhasil diperbarui') {
      return 'Foto toko diperbarui';
    }
    return message;
  }

  String? _alertSubtitle(String message) {
    if (message == 'Profil berhasil disimpan') {
      return 'Informasi toko rental sudah tersimpan.';
    }
    if (message == 'Foto profil berhasil diperbarui') {
      return 'Foto baru sudah masuk ke profil toko.';
    }
    return null;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OwnerProfileColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: OwnerProfileColors.green,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OwnerProfileHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 20),
                    OwnerProfileAvatar(
                      photoUrl: _fotoProfil,
                      displayName: _namaTokoC.text.isNotEmpty
                          ? _namaTokoC.text
                          : widget.name,
                      email: _emailC.text.isNotEmpty
                          ? _emailC.text
                          : widget.email,
                      uploading: _uploadingPhoto,
                    ),
                    const SizedBox(height: 12),
                    OwnerChangePhotoButton(
                      uploading: _uploadingPhoto,
                      onPressed: _pickAndUploadPhoto,
                    ),
                    const SizedBox(height: 16),
                    _storeDetailCard(),
                    const SizedBox(height: 12),
                    _financeDetailCard(),
                    const SizedBox(height: 12),
                    _accountCard(),
                    const SizedBox(height: 24),
                    OwnerProfileSaveButton(
                      saving: _saving,
                      onPressed: _saveProfile,
                    ),
                    const SizedBox(height: 12),
                    OwnerProfileCancelButton(
                      saving: _saving,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _storeDetailCard() {
    return OwnerProfileCard(
      title: 'Detail Toko',
      children: [
        OwnerProfileTextField(hint: 'Nama Toko', controller: _namaTokoC),
        OwnerProfileTextField(
          hint: 'Nomor Telepon',
          controller: _nomorTeleponC,
          keyboardType: TextInputType.phone,
        ),
        OwnerLocationDropdown(
          value: _lokasiId,
          items: _lokasiList,
          onChanged: (val) => setState(() => _lokasiId = val),
        ),
        OwnerProfileTextField(
          hint: 'Jam Operasional',
          controller: _jamOperasionalC,
        ),
        OwnerProfileTextField(
          hint: 'Alamat',
          controller: _alamatC,
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _financeDetailCard() {
    return OwnerProfileCard(
      title: 'Detail Keuangan',
      children: [
        OwnerBankDropdown(
          value: _bankC.text,
          options: _bankOptions,
          onChanged: (val) => setState(() => _bankC.text = val ?? ''),
        ),
        OwnerProfileTextField(
          hint: 'Nomor Rekening',
          controller: _nomorRekeningC,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  Widget _accountCard() {
    return OwnerProfileCard(
      title: 'Akun Rental',
      children: [
        OwnerProfileTextField(
          hint: 'Email',
          controller: _emailC,
          readOnly: true,
        ),
        OwnerPasswordField(
          controller: _passwordC,
          obscureText: _obscurePassword,
          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
      ],
    );
  }
}
