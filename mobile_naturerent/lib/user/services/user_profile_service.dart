import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserProfileData {
  const UserProfileData({
    this.user,
    required this.locations,
    this.profile,
  });

  final Map<String, dynamic>? user;
  final List<Map<String, dynamic>> locations;
  final Map<String, dynamic>? profile;
}

class UserProfilePayload {
  const UserProfilePayload({
    required this.userId,
    required this.lokasiId,
    required this.firstName,
    required this.lastName,
    required this.birthDate,
    required this.phone,
    required this.province,
    required this.photoUrl,
  });

  final dynamic userId;
  final int lokasiId;
  final String firstName;
  final String lastName;
  final String birthDate;
  final String phone;
  final String province;
  final String? photoUrl;

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'lokasi_id': lokasiId,
      'first_name': firstName,
      'last_name': lastName,
      'birth_date': birthDate,
      'phone': phone,
      'provinsi': province,
      'profile_photo_url': photoUrl,
    };
  }
}

class UserProfileService {
  UserProfileService({SupabaseClient? client})
      : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;
  static const _photoBucket = 'user-profile';

  Future<UserProfileData> loadProfile(dynamic userId) async {
    final user = await _supabase
        .from('users')
        .select('nama, email')
        .eq('id_user', userId)
        .maybeSingle();

    final lokasi = await _supabase
        .from('lokasi')
        .select('id_lokasi, nama_kota');

    final profile = await _supabase
        .from('user_profiles')
        .select(
          'lokasi_id, first_name, last_name, birth_date, phone, provinsi, profile_photo_url',
        )
        .eq('user_id', userId)
        .maybeSingle();

    return UserProfileData(
      user: user,
      locations: List<Map<String, dynamic>>.from(lokasi),
      profile: profile,
    );
  }

  Future<String?> pickAndUploadPhoto({
    required dynamic userId,
    required String? oldPhotoUrl,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    final bytes = await _readFileBytes(file);
    if (bytes == null) {
      throw Exception('Gagal membaca foto');
    }

    final ext = (file.extension ?? '').toLowerCase();
    final path = '$userId/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';

    await _supabase.storage.from(_photoBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    final url = _supabase.storage.from(_photoBucket).getPublicUrl(path);
    await _removeOldPhoto(oldPhotoUrl);
    return url;
  }

  Future<void> saveProfile({
    required String username,
    required UserProfilePayload payload,
  }) async {
    await _supabase
        .from('users')
        .update({'nama': username})
        .eq('id_user', payload.userId);

    final existing = await _supabase
        .from('user_profiles')
        .select('id_user_profile')
        .eq('user_id', payload.userId)
        .maybeSingle();

    if (existing == null) {
      await _supabase.from('user_profiles').insert(payload.toMap());
    } else {
      await _supabase
          .from('user_profiles')
          .update(payload.toMap())
          .eq('id_user_profile', existing['id_user_profile']);
    }
  }

  Future<Uint8List?> _readFileBytes(PlatformFile file) async {
    if (file.bytes != null) return file.bytes;
    if (file.path == null) return null;
    return File(file.path!).readAsBytes();
  }

  Future<void> _removeOldPhoto(String? oldPhotoUrl) async {
    if (oldPhotoUrl == null) return;

    final oldPath = _extractPathFromPublicUrl(oldPhotoUrl);
    if (oldPath == null) return;

    await _supabase.storage.from(_photoBucket).remove([oldPath]);
  }

  String? _extractPathFromPublicUrl(String url) {
    try {
      final segments = Uri.parse(url).pathSegments;
      final bucketIndex = segments.indexOf(_photoBucket);
      if (bucketIndex == -1) return null;
      return segments.sublist(bucketIndex + 1).join('/');
    } catch (_) {
      return null;
    }
  }
}
