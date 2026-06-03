import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/session_manager.dart';

class UserPesananService {
  UserPesananService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> fetchPesanan() async {
    final userId = await _currentUserId();
    if (userId == null) return [];

    final data = await _supabase
        .from('transaksi')
        .select(
          '*, transaksi_item(*, products(name, image_url, price_per_day, owner(nama_toko)), reviews(id_review))',
        )
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, dynamic>> cancelPesanan(dynamic transactionId) async {
    final userId = await _currentUserId();
    if (userId == null) {
      throw Exception('User belum login');
    }

    final current = await _supabase
        .from('transaksi')
        .select('id_transaksi, status_pesanan')
        .eq('id_transaksi', transactionId)
        .eq('user_id', userId)
        .maybeSingle();

    if (current == null) {
      throw Exception('Pesanan tidak ditemukan');
    }

    final status = _normalizeStatus(current['status_pesanan']);
    final canCancel =
        status == 'menunggu_konfirmasi' ||
        status == 'menunggu' ||
        status == 'dipesan';

    if (!canCancel) {
      throw Exception('Pesanan ini tidak bisa dibatalkan');
    }

    final updated = await _supabase
        .from('transaksi')
        .update({
          'status_pesanan': 'dibatalkan',
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_transaksi', transactionId)
        .eq('user_id', userId)
        .select('id_transaksi, status_pesanan')
        .maybeSingle();

    if (updated == null) {
      throw Exception('Gagal membatalkan pesanan');
    }

    await _returnProductStock(transactionId);

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

  String _normalizeStatus(dynamic value) {
    return (value ?? '').toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
  }

  Future<dynamic> _currentUserId() async {
    final appSession = await SessionManager.loadSession();
    if (appSession?.userId != null) return appSession!.userId;

    final authUser =
        _supabase.auth.currentUser ?? _supabase.auth.currentSession?.user;
    return authUser?.id;
  }
}
