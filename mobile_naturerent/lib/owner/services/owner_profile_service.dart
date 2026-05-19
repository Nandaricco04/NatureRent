import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerProfileData {
  const OwnerProfileData({
    required this.email,
    required this.lokasiList,
    this.namaToko = '',
    this.nomorTelepon = '',
    this.jamOperasional = '',
    this.alamat = '',
    this.bank = '',
    this.nomorRekening = '',
    this.lokasiId,
    this.fotoProfil,
  });

  final String email;
  final String namaToko;
  final String nomorTelepon;
  final String jamOperasional;
  final String alamat;
  final String bank;
  final String nomorRekening;
  final int? lokasiId;
  final String? fotoProfil;
  final List<Map<String, dynamic>> lokasiList;
}

class OwnerProfileUpdate {
  const OwnerProfileUpdate({
    required this.namaToko,
    required this.nomorTelepon,
    required this.lokasiId,
    required this.jamOperasional,
    required this.alamat,
    required this.bank,
    required this.nomorRekening,
    this.fotoProfil,
  });

  final String namaToko;
  final String nomorTelepon;
  final int lokasiId;
  final String jamOperasional;
  final String alamat;
  final String bank;
  final String nomorRekening;
  final String? fotoProfil;
}

class OwnerProfileService {
  OwnerProfileService({SupabaseClient? client, ImagePicker? picker})
    : _supabase = client ?? Supabase.instance.client,
      _picker = picker ?? ImagePicker();

  final SupabaseClient _supabase;
  final ImagePicker _picker;
  static const _ownerDocsBucket = 'owner-docs';
  static const _profilePhotoFolder = 'foto_profil';

  Future<OwnerProfileData> fetchProfile({
    required dynamic userId,
    required String fallbackEmail,
  }) async {
    final user = await _supabase
        .from('users')
        .select('email')
        .eq('id_user', userId)
        .maybeSingle();

    final owner = await _supabase
        .from('owner')
        .select(
          'nama_toko, nomor_telepon, lokasi_id, jam_operasional, '
          'alamat, bank, nomor_rekening, foto_profil',
        )
        .eq('user_id', userId)
        .maybeSingle();

    final lokasi = await _supabase
        .from('lokasi')
        .select('id_lokasi, nama_kota')
        .order('nama_kota');

    final foto = (owner?['foto_profil'] ?? '').toString();

    return OwnerProfileData(
      email: (user?['email'] ?? fallbackEmail).toString(),
      namaToko: (owner?['nama_toko'] ?? '').toString(),
      nomorTelepon: (owner?['nomor_telepon'] ?? '').toString(),
      jamOperasional: (owner?['jam_operasional'] ?? '').toString(),
      alamat: (owner?['alamat'] ?? '').toString(),
      bank: (owner?['bank'] ?? '').toString(),
      nomorRekening: (owner?['nomor_rekening'] ?? '').toString(),
      lokasiId: owner?['lokasi_id'] as int?,
      fotoProfil: foto.isEmpty ? null : foto,
      lokasiList: List<Map<String, dynamic>>.from(lokasi),
    );
  }

  Future<String?> pickAndUploadPhoto({required dynamic userId}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    final ext = picked.name.split('.').last.toLowerCase();
    final filePath =
        '$_profilePhotoFolder/'
        'owner_${userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';

    await _supabase.storage
        .from(_ownerDocsBucket)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: ext == 'png' ? 'image/png' : 'image/jpeg',
            upsert: true,
          ),
        );

    return _supabase.storage.from(_ownerDocsBucket).getPublicUrl(filePath);
  }

  Future<void> updateProfile({
    required dynamic userId,
    required OwnerProfileUpdate profile,
  }) async {
    await _supabase
        .from('owner')
        .update({
          'nama_toko': profile.namaToko,
          'nomor_telepon': profile.nomorTelepon,
          'lokasi_id': profile.lokasiId,
          'jam_operasional': profile.jamOperasional,
          'alamat': profile.alamat,
          'bank': profile.bank,
          'nomor_rekening': profile.nomorRekening,
          if (profile.fotoProfil != null) 'foto_profil': profile.fotoProfil,
        })
        .eq('user_id', userId);
  }

  Future<void> updatePassword(String password) async {
    await _supabase.auth.updateUser(UserAttributes(password: password));
  }
}
