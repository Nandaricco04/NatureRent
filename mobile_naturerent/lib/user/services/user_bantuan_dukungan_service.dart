import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupportAttachment {
  const SupportAttachment({
    required this.name,
    required this.bytes,
    required this.url,
  });

  final String name;
  final Uint8List bytes;
  final String url;
}

class SupportPayload {
  const SupportPayload({
    required this.userId,
    required this.namaPengguna,
    required this.email,
    required this.nomorTelepon,
    required this.idPesanan,
    required this.category,
    required this.description,
    this.attachmentUrl,
  });

  final dynamic userId;
  final String namaPengguna;
  final String email;
  final String nomorTelepon;
  final String idPesanan;
  final String category;
  final String description;
  final String? attachmentUrl;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'nama_pengguna': namaPengguna,
      'email': email,
      'nomor_telepon': nomorTelepon,
      'id_pesanan': idPesanan,
      'category': category,
      'description': description,
      'attachment_url': attachmentUrl,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

class UserBantuanDukunganService {
  UserBantuanDukunganService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<Map<String, dynamic>?> loadUser(dynamic userId) {
    return _supabase
        .from('users')
        .select('nama, email')
        .eq('id_user', userId)
        .maybeSingle();
  }

  Future<SupportAttachment?> pickAndUploadAttachment(dynamic userId) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1200,
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final cleanName = picked.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_$cleanName';

    await _supabase.storage.from('support_image').uploadBinary(path, bytes);

    return SupportAttachment(
      name: picked.name,
      bytes: bytes,
      url: _supabase.storage.from('support_image').getPublicUrl(path),
    );
  }

  Future<void> submit(SupportPayload payload) {
    return _supabase.from('support').insert(payload.toMap());
  }
}
