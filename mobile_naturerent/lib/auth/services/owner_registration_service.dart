import 'package:bcrypt/bcrypt.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerRegistrationPayload {
  const OwnerRegistrationPayload({
    required this.namaToko,
    required this.nomorTelepon,
    required this.lokasiId,
    required this.jamOperasional,
    required this.alamat,
    required this.fotoProfil,
    required this.fotoKtp,
    required this.fotoNpwp,
    required this.fotoTempatUsaha,
    required this.fotoNib,
    required this.bank,
    required this.nomorRekening,
    required this.namaLengkap,
    required this.email,
    required this.password,
  });

  final String namaToko;
  final String nomorTelepon;
  final int lokasiId;
  final String jamOperasional;
  final String alamat;
  final String? fotoProfil;
  final String? fotoKtp;
  final String? fotoNpwp;
  final String? fotoTempatUsaha;
  final String? fotoNib;
  final String bank;
  final String nomorRekening;
  final String namaLengkap;
  final String email;
  final String password;
}

class OwnerRegistrationService {
  OwnerRegistrationService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> loadLokasi() async {
    final data = await _supabase.from('lokasi').select('id_lokasi, nama_kota');
    return List<Map<String, dynamic>>.from(data);
  }

  Future<bool> isEmailRegistered(String email) async {
    final existing = await _supabase
        .from('users')
        .select('email')
        .eq('email', email)
        .maybeSingle();

    return existing != null;
  }

  Future<void> registerOwner(OwnerRegistrationPayload payload) async {
    final hash = BCrypt.hashpw(payload.password, BCrypt.gensalt());

    final userRow = await _supabase
        .from('users')
        .insert({
          'nama': payload.namaLengkap,
          'email': payload.email,
          'password': hash,
          'role': 'pemilikRental',
        })
        .select('id_user')
        .single();

    final userId = userRow['id_user'];

    await _supabase.from('owner').insert({
      'user_id': userId,
      'nama_toko': payload.namaToko,
      'nomor_telepon': payload.nomorTelepon,
      'lokasi_id': payload.lokasiId,
      'jam_operasional': payload.jamOperasional,
      'alamat': payload.alamat,
      'foto_profil': payload.fotoProfil,
      'foto_ktp': payload.fotoKtp,
      'foto_npwp': payload.fotoNpwp,
      'foto_tempat_usaha': payload.fotoTempatUsaha,
      'foto_nib': payload.fotoNib,
      'bank': payload.bank,
      'nomor_rekening': payload.nomorRekening,
      'status_verifikasi': 'pending',
    });
  }
}
