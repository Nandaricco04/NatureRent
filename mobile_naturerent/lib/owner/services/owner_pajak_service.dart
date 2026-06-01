import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerPajakService {
  OwnerPajakService({SupabaseClient? client, ImagePicker? picker})
    : _supabase = client ?? Supabase.instance.client,
      _picker = picker ?? ImagePicker();

  static const proofBucket = 'bukti_pembayaran_pajak';

  final SupabaseClient _supabase;
  final ImagePicker _picker;

  Future<String?> pickAndUploadTaxProof(dynamic transactionId) async {
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
        'pajak/$transactionId/${DateTime.now().millisecondsSinceEpoch}_$cleanName';

    await _supabase.storage
        .from(proofBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return _supabase.storage.from(proofBucket).getPublicUrl(path);
  }

  Future<Map<String, dynamic>> submitTaxProof({
    required dynamic transactionId,
    required String proofUrl,
  }) async {
    final updated = await _supabase
        .from('transaksi')
        .update({
          'bukti_pajak': proofUrl,
          'status_pajak': 'menunggu_verifikasi',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_transaksi', transactionId)
        .select('id_transaksi, bukti_pajak, status_pajak')
        .maybeSingle();

    if (updated == null) {
      throw Exception('Data pajak tidak ditemukan');
    }

    return Map<String, dynamic>.from(updated);
  }
}
