import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../widgets/app_alerts.dart';
import 'services/user_bantuan_dukungan_service.dart';
import 'widgets/user_bantuan_dukungan_widgets.dart';

class UserBantuanDukunganPage extends StatefulWidget {
  const UserBantuanDukunganPage({
    super.key,
    required this.userId,
    this.name,
    this.email,
  });

  final dynamic userId;
  final String? name;
  final String? email;

  @override
  State<UserBantuanDukunganPage> createState() =>
      _UserBantuanDukunganPageState();
}

class _UserBantuanDukunganPageState extends State<UserBantuanDukunganPage> {
  final _service = UserBantuanDukunganService();

  final _namaC = TextEditingController();
  final _emailC = TextEditingController();
  final _teleponC = TextEditingController();
  final _pesananC = TextEditingController();
  final _kategoriC = TextEditingController();
  final _deskripsiC = TextEditingController();

  Uint8List? _imageBytes;
  String? _imageName;
  String? _attachmentUrl;
  bool _loadingProfile = true;
  bool _saving = false;
  bool _uploadingAttachment = false;

  @override
  void initState() {
    super.initState();
    _namaC.text = widget.name ?? '';
    _emailC.text = widget.email ?? '';
    _loadUserData();
  }

  @override
  void dispose() {
    _namaC.dispose();
    _emailC.dispose();
    _teleponC.dispose();
    _pesananC.dispose();
    _kategoriC.dispose();
    _deskripsiC.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await _service.loadUser(widget.userId);
      if (user != null) {
        _namaC.text = (user['nama'] ?? '').toString();
        _emailC.text = (user['email'] ?? '').toString();
      }
    } catch (_) {
      // Tetap tampilkan data yang dikirim dari halaman profile jika query gagal.
    } finally {
      if (mounted) setState(() => _loadingProfile = false);
    }
  }

  Future<void> _pickImage() async {
    setState(() => _uploadingAttachment = true);
    try {
      final attachment = await _service.pickAndUploadAttachment(widget.userId);
      if (attachment == null) return;

      if (!mounted) return;
      setState(() {
        _imageBytes = attachment.bytes;
        _imageName = attachment.name;
        _attachmentUrl = attachment.url;
      });
    } catch (e) {
      _show('Upload lampiran gagal: $e');
    } finally {
      if (mounted) setState(() => _uploadingAttachment = false);
    }
  }

  Future<void> _submit() async {
    final nama = _namaC.text.trim();
    final email = _emailC.text.trim();
    final telepon = _teleponC.text.trim();
    final pesanan = _pesananC.text.trim();
    final kategori = _kategoriC.text.trim();
    final deskripsi = _deskripsiC.text.trim();

    if (nama.isEmpty ||
        email.isEmpty ||
        telepon.isEmpty ||
        pesanan.isEmpty ||
        kategori.isEmpty ||
        deskripsi.isEmpty) {
      _show('Semua field wajib diisi');
      return;
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(telepon)) {
      _show('Nomor telepon hanya boleh berisi angka');
      return;
    }

    if (_uploadingAttachment) {
      _show('Tunggu upload lampiran selesai');
      return;
    }

    if (_imageBytes != null && _attachmentUrl == null) {
      _show('Lampiran belum berhasil diupload');
      return;
    }

    setState(() => _saving = true);

    try {
      await _service.submit(
        SupportPayload(
          userId: widget.userId,
          namaPengguna: nama,
          email: email,
          nomorTelepon: telepon,
          idPesanan: pesanan,
          category: kategori,
          description: deskripsi,
          attachmentUrl: _attachmentUrl,
        ),
      );

      if (!mounted) return;
      _show('Complain berhasil dikirim');
      Navigator.pop(context);
    } catch (e) {
      _show('Gagal mengirim complain: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _clearAttachment() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _attachmentUrl = null;
    });
  }

  void _show(String message) {
    AppAlerts.showSnackBar(
      context,
      message: message,
      type: _alertType(message),
    );
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal') || lower.contains('belum berhasil')) {
      return AppAlertType.error;
    }
    return AppAlertType.warning;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UserSupportColors.background,
      body: SafeArea(
        child: _loadingProfile
            ? const Center(
                child: CircularProgressIndicator(
                  color: UserSupportColors.green,
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(15, 28, 15, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UserSupportHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 22),
                    const UserSupportIntro(),
                    const SizedBox(height: 18),
                    UserSupportFormCard(
                      title: 'Informasi Pribadi',
                      children: [
                        UserSupportTextField(
                          hint: 'Nama Pengguna',
                          controller: _namaC,
                        ),
                        UserSupportTextField(
                          hint: 'Email',
                          controller: _emailC,
                          readOnly: true,
                        ),
                        UserSupportTextField(
                          hint: 'Nomor Telepon',
                          controller: _teleponC,
                          keyboardType: TextInputType.phone,
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    UserSupportFormCard(
                      title: 'Bantuan',
                      children: [
                        UserSupportTextField(
                          hint: 'ID Pesanan',
                          controller: _pesananC,
                        ),
                        UserSupportTextField(
                          hint: 'Kategori Masalah',
                          controller: _kategoriC,
                        ),
                        UserSupportTextField(
                          hint: 'Deskripsi Masalah',
                          controller: _deskripsiC,
                          maxLines: 3,
                        ),
                        UserSupportAttachmentField(
                          imageName: _imageName,
                          uploading: _uploadingAttachment,
                          disabled: _saving,
                          onPick: _pickImage,
                          onClear: _clearAttachment,
                        ),
                        if (_imageBytes != null)
                          UserSupportAttachmentPreview(
                            bytes: _imageBytes!,
                            url: _attachmentUrl,
                            uploading: _uploadingAttachment,
                            disabled: _saving,
                            onClear: _clearAttachment,
                          ),
                      ],
                    ),
                    const SizedBox(height: 44),
                    UserSupportActionButtons(
                      saving: _saving,
                      onSubmit: _submit,
                      onCancel: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
