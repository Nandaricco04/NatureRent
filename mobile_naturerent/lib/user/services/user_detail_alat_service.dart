import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/session_manager.dart';

class UserDetailCartSession {
  const UserDetailCartSession({
    required this.userId,
    this.cartId,
    this.name,
    this.email,
  });

  final dynamic userId;
  final dynamic cartId;
  final String? name;
  final String? email;
}

class UserDetailCartException implements Exception {
  const UserDetailCartException(this.message);

  final String message;

  @override
  String toString() => message;
}

class UserDetailAlatService {
  UserDetailAlatService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<Map<String, dynamic>?> fetchProduct(String productIdText) async {
    final productId = _parseId(productIdText);

    return _supabase
        .from('products')
        .select(
          '*, owner(nama_toko,alamat,nomor_telepon,foto_profil), categories(name)',
        )
        .eq('id_product', productId)
        .maybeSingle();
  }

  Future<List<dynamic>> fetchReviews(String productIdText) async {
    final productId = _parseId(productIdText);

    return _supabase
        .from('reviews')
        .select('*, users(nama)')
        .eq('product_id', productId)
        .order('created_at', ascending: false);
  }

  Future<UserDetailCartSession> addToCart({
    required String productIdText,
    required Map<String, dynamic> product,
    required int quantity,
    required DateTime startDate,
    required DateTime endDate,
    required int totalDays,
    required int totalPrice,
  }) async {
    final session = await _currentSession();
    if (session == null) {
      throw const UserDetailCartException('User belum login');
    }

    final productId = _parseId(productIdText);
    final start = DateFormat('yyyy-MM-dd').format(startDate);
    final end = DateFormat('yyyy-MM-dd').format(endDate);
    final pricePerDay = ((product['price_per_day'] ?? 0) as num).toInt();

    final existingCart = await _supabase
        .from('keranjang')
        .select('id_keranjang, jumlah')
        .eq('user_id', session.userId)
        .eq('product_id', productId)
        .eq('tanggal_mulai', start)
        .eq('tanggal_kembali', end)
        .maybeSingle();

    dynamic cartId;

    if (existingCart != null) {
      final oldQuantity = ((existingCart['jumlah'] ?? 0) as num).toInt();
      final newQuantity = oldQuantity + quantity;
      cartId = existingCart['id_keranjang'];

      await _supabase
          .from('keranjang')
          .update({
            'jumlah': newQuantity,
            'total_hari': totalDays,
            'harga_per_hari': pricePerDay,
            'subtotal': pricePerDay * totalDays * newQuantity,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id_keranjang', existingCart['id_keranjang']);
    } else {
      final inserted = await _supabase
          .from('keranjang')
          .insert({
            'user_id': session.userId,
            'product_id': productId,
            'tanggal_mulai': start,
            'tanggal_kembali': end,
            'total_hari': totalDays,
            'jumlah': quantity,
            'harga_per_hari': pricePerDay,
            'subtotal': totalPrice,
          })
          .select('id_keranjang')
          .single();
      cartId = inserted['id_keranjang'];
    }

    return UserDetailCartSession(
      userId: session.userId,
      cartId: cartId,
      name: session.name,
      email: session.email,
    );
  }

  Future<UserDetailCartSession?> _currentSession() async {
    final authUser =
        _supabase.auth.currentUser ?? _supabase.auth.currentSession?.user;
    final appSession = await SessionManager.loadSession();
    final userId = authUser?.id ?? appSession?.userId;

    if (userId == null) return null;

    return UserDetailCartSession(
      userId: userId,
      name: appSession?.name,
      email: authUser?.email ?? appSession?.email,
    );
  }

  dynamic _parseId(String value) => int.tryParse(value) ?? value;
}
