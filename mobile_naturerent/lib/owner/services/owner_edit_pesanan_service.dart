import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerEditPesananService {
  OwnerEditPesananService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<Map<String, dynamic>> updateOrderStatus({
    required dynamic transactionId,
    required String status,
    required String paymentMethod,
  }) async {
    final current = await _supabase
        .from('transaksi')
        .select('id_transaksi, status_pesanan')
        .eq('id_transaksi', transactionId)
        .maybeSingle();

    if (current == null) {
      throw Exception('Data pesanan tidak ditemukan atau tidak bisa diubah');
    }

    final oldStatus = (current['status_pesanan'] ?? '').toString();
    final shouldReturnStock =
        _normalizeStatus(oldStatus) != 'selesai' &&
        _normalizeStatus(status) == 'selesai';

    final updated = await _supabase
        .from('transaksi')
        .update({
          'status_pesanan': status,
          if (status == 'dipesan' && paymentMethod.toLowerCase() == 'qris')
            'status_payment': 'dibayar',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_transaksi', transactionId)
        .select('id_transaksi, status_pesanan')
        .maybeSingle();

    if (updated == null) {
      throw Exception('Data pesanan tidak ditemukan atau tidak bisa diubah');
    }

    if (shouldReturnStock) {
      await _returnProductStock(transactionId);
    }

    return Map<String, dynamic>.from(updated);
  }

  Future<void> _returnProductStock(dynamic transactionId) async {
    final rows = await _supabase
        .from('transaksi_item')
        .select('product_id, jumlah')
        .eq('transaksi_id', transactionId);

    final quantities = <dynamic, int>{};
    for (final row in List<Map<String, dynamic>>.from(rows)) {
      final productId = row['product_id'];
      if (productId == null) continue;
      quantities[productId] =
          (quantities[productId] ?? 0) + _readInt(row['jumlah']);
    }

    for (final entry in quantities.entries) {
      final product = await _supabase
          .from('products')
          .select('id_product, stock')
          .eq('id_product', entry.key)
          .maybeSingle();

      if (product == null) continue;

      await _supabase
          .from('products')
          .update({'stock': _readInt(product['stock']) + entry.value})
          .eq('id_product', entry.key);
    }
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  String _normalizeStatus(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '_');
  }
}
