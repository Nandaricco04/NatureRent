import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerStoreProfile {
  const OwnerStoreProfile({
    required this.ownerId,
    required this.storeName,
    required this.email,
    this.photoUrl,
  });

  final dynamic ownerId;
  final String storeName;
  final String email;
  final String? photoUrl;
}

class OwnerMainService {
  OwnerMainService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<OwnerStoreProfile> fetchStoreProfile(dynamic userId) async {
    final user = await _supabase
        .from('users')
        .select('email')
        .eq('id_user', userId)
        .maybeSingle();

    final owner = await _supabase
        .from('owner')
        .select('id_owner, nama_toko, foto_profil')
        .eq('user_id', userId)
        .maybeSingle();

    final photo = (owner?['foto_profil'] ?? '').toString();

    return OwnerStoreProfile(
      ownerId: owner?['id_owner'],
      storeName: (owner?['nama_toko'] ?? 'Toko Rental').toString(),
      email: (user?['email'] ?? 'owner@gmail.com').toString(),
      photoUrl: photo.isEmpty ? null : photo,
    );
  }
}
