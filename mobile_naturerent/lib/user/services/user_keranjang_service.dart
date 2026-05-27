import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/session_manager.dart';

class UserKeranjangService {
  UserKeranjangService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> fetchCart() async {
    final userId = await currentUserId();
    if (userId == null) return [];

    final data = await _supabase
        .from('keranjang')
        .select('''
          *,
          products(
            id_product,
            owner_id,
            name,
            image_url,
            price_per_day,
            stock,
            owner(
              nama_toko
            )
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<void> updateQuantity(
    Map<String, dynamic> item,
    int newQuantity,
  ) async {
    final idKeranjang = item['id_keranjang'];

    if (newQuantity <= 0) {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_keranjang', idKeranjang);
      return;
    }

    final hargaPerHari = _readInt(item['harga_per_hari']);
    final totalHari = _readInt(item['total_hari']);

    await _supabase
        .from('keranjang')
        .update({
          'jumlah': newQuantity,
          'subtotal': hargaPerHari * totalHari * newQuantity,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id_keranjang', idKeranjang);
  }

  Future<String> checkout({
    required List<Map<String, dynamic>> selectedCarts,
    required String paymentMethod,
    required int subtotalSewa,
    required int pajak,
    required int totalHarga,
  }) async {
    final userId = await currentUserId();
    if (userId == null) {
      throw const UserKeranjangException('User belum login');
    }

    final transaksi = await _supabase
        .from('transaksi')
        .insert({
          'user_id': userId,
          'payment_method': paymentMethod,
          'status_payment': 'pending',
          'status_pesanan': 'menunggu_konfirmasi',
          'subtotal_sewa': subtotalSewa,
          'pajak': pajak,
          'total_harga': totalHarga,
        })
        .select('id_transaksi, kode_transaksi')
        .single();

    final idTransaksi = transaksi['id_transaksi'];
    final items = selectedCarts.map((item) {
      final product = item['products'] as Map<String, dynamic>?;

      return {
        'id_transaksi': idTransaksi,
        'product_id': item['product_id'],
        'nama_produk': product?['name'] ?? 'Alat outdoor',
        'tanggal_mulai': item['tanggal_mulai'],
        'tanggal_kembali': item['tanggal_kembali'],
        'total_hari': item['total_hari'],
        'jumlah': item['jumlah'],
        'harga_per_hari': item['harga_per_hari'],
        'subtotal': item['subtotal'],
      };
    }).toList();

    await _supabase.from('transaksi_item').insert(items);

    for (final item in selectedCarts) {
      await _supabase
          .from('keranjang')
          .delete()
          .eq('id_keranjang', item['id_keranjang']);
    }

    return (transaksi['kode_transaksi'] ?? 'ID$idTransaksi').toString();
  }

  Future<dynamic> currentUserId() async {
    final authUser =
        _supabase.auth.currentUser ?? _supabase.auth.currentSession?.user;
    if (authUser != null) return authUser.id;

    final appSession = await SessionManager.loadSession();
    return appSession?.userId;
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }
}

class UserKeranjangException implements Exception {
  const UserKeranjangException(this.message);

  final String message;

  @override
  String toString() => message;
}
