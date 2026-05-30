import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class IklanPackage {
  const IklanPackage({
    required this.id,
    required this.durationDays,
    required this.pricePerDay,
  });

  final dynamic id;
  final int durationDays;
  final int pricePerDay;

  int get total => durationDays * pricePerDay;
}

class OwnerIklanService {
  OwnerIklanService({SupabaseClient? client, ImagePicker? picker})
      : _supabase = client ?? Supabase.instance.client,
        _picker = picker ?? ImagePicker();

  final SupabaseClient _supabase;
  final ImagePicker _picker;

  static const _proofBucket = 'bukti_pembayaran_iklan';

  Future<List<IklanPackage>> fetchPackages() async {
    final rows = await _supabase.from('paket_iklan').select();
    final packages = List<Map<String, dynamic>>.from(rows)
        .map(_packageFromRow)
        .whereType<IklanPackage>()
        .toList()
      ..sort((a, b) => a.durationDays.compareTo(b.durationDays));

    return packages;
  }

  Future<String?> pickAndUploadProof({required dynamic userId}) async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    if (bytes.length > 3 * 1024 * 1024) {
      throw Exception('Ukuran bukti pembayaran maksimal 3 MB');
    }

    final cleanName = picked.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final ext = cleanName.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final path =
        'bukti_iklan/$userId/${DateTime.now().millisecondsSinceEpoch}_$cleanName';

    await _supabase.storage.from(_proofBucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return _supabase.storage.from(_proofBucket).getPublicUrl(path);
  }

  Future<void> createAdvertisement({
    required dynamic userId,
    required dynamic productId,
    required IklanPackage package,
    required String proofUrl,
  }) async {
    final now = DateTime.now();
    final endDate = now.add(Duration(days: package.durationDays));

    await _supabase.from('iklan_sewa').insert({
      'user_id': userId,
      'alat_id': productId,
      'paket_iklan_id': package.id,
      'tanggal_mulai': now.toIso8601String(),
      'tanggal_selesai': endDate.toIso8601String(),
      'total_bayar': package.total,
      'metode_pembayaran': 'QRIS',
      'bukti_pembayaran': proofUrl,
      'status': 'menunggu_verifikasi',
      'created_at': now.toIso8601String(),
      'updated_at': now.toIso8601String(),
    });
  }

  IklanPackage? _packageFromRow(Map<String, dynamic> row) {
    final id = row['id_paket_iklan'] ?? row['id_paket'] ?? row['id'];
    final duration = _toInt(
      row['durasi_hari'] ?? row['durasi'] ?? row['hari'] ?? row['days'],
    );
    final pricePerDay = _toInt(
      row['harga_per_hari'] ??
          row['harga_harian'] ??
          row['harga_perhari'] ??
          row['harga_paket'] ??
          row['harga'] ??
          row['price_per_day'] ??
          row['price'],
    );

    if (id == null || duration == null || pricePerDay == null) return null;
    return IklanPackage(
      id: id,
      durationDays: duration,
      pricePerDay: pricePerDay,
    );
  }

  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
