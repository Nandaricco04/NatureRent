import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/session_manager.dart';

class UserKeranjangService {
  UserKeranjangService({SupabaseClient? client, ImagePicker? picker})
    : _supabase = client ?? Supabase.instance.client,
      _picker = picker ?? ImagePicker();

  final SupabaseClient _supabase;
  final ImagePicker _picker;

  static const _proofBucket = 'bukti_pembayaran_sewa';

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

  Future<List<String>> checkout({
    required List<Map<String, dynamic>> selectedCarts,
    required String paymentMethod,
    String? buktiPembayaran,
  }) async {
    final userId = await currentUserId();
    if (userId == null) {
      throw const UserKeranjangException('User belum login');
    }

    final userIdInt = _readInt(userId);
    if (userIdInt <= 0) {
      throw const UserKeranjangException('Session user tidak valid');
    }

    final cartsByOwner = <String, List<int>>{};
    for (final cart in selectedCarts) {
      final cartId = _readInt(cart['id_keranjang']);
      final ownerId = _ownerId(cart);
      if (cartId <= 0 || ownerId == null) {
        throw const UserKeranjangException(
          'Data toko pada keranjang tidak valid',
        );
      }
      cartsByOwner.putIfAbsent(ownerId, () => []).add(cartId);
    }

    if (cartsByOwner.isEmpty) {
      throw const UserKeranjangException('Keranjang belum dipilih');
    }

    final transactionCodes = <String>[];

    for (final cartIds in cartsByOwner.values) {
      final result = await _supabase.rpc(
        'checkout_sewa',
        params: {
          'p_user_id': userIdInt,
          'p_cart_ids': cartIds,
          'p_payment_method': paymentMethod,
          'p_bukti_pembayaran': buktiPembayaran,
        },
      );

      final row = _firstRpcRow(result);
      final idTransaksi = row?['id_transaksi'];
      if (idTransaksi == null) {
        throw const UserKeranjangException('ID transaksi gagal dibuat');
      }

      final transactionCode =
          (row?['kode_transaksi'] ?? _formatTransactionCode(idTransaksi))
              .toString();
      transactionCodes.add(transactionCode);

      await _createNotification(
        userId: userIdInt,
        transactionId: idTransaksi,
        type: 'booking_success',
        title: 'Booking Berhasil',
        message:
            'Pesanan $transactionCode berhasil dibuat. Cek detail booking di halaman pesanan.',
      );

      if (paymentMethod.toLowerCase() == 'qris') {
        await _supabase
            .from('transaksi')
            .update({'status_pajak': 'sudah_dibayar'})
            .eq('id_transaksi', idTransaksi);
      }
    }

    return transactionCodes;
  }

  Future<void> _createNotification({
    required dynamic userId,
    required dynamic transactionId,
    required String type,
    required String title,
    required String message,
  }) async {
    await _supabase.rpc(
      'create_notification',
      params: {
        'p_user_id': userId,
        'p_transaksi_id': transactionId,
        'p_type': type,
        'p_title': title,
        'p_message': message,
      },
    );
  }

  Future<String?> pickAndUploadPaymentProof() async {
    final userId = await currentUserId();
    if (userId == null) {
      throw const UserKeranjangException('User belum login');
    }

    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600,
    );

    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    if (bytes.length > 3 * 1024 * 1024) {
      throw const UserKeranjangException(
        'Ukuran bukti pembayaran maksimal 3 MB',
      );
    }

    final cleanName = picked.name.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final ext = cleanName.split('.').last.toLowerCase();
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final path =
        'checkout/$userId/${DateTime.now().millisecondsSinceEpoch}_$cleanName';

    await _supabase.storage
        .from(_proofBucket)
        .uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(contentType: contentType),
        );

    return _supabase.storage.from(_proofBucket).getPublicUrl(path);
  }

  Future<dynamic> currentUserId() async {
    final appSession = await SessionManager.loadSession();
    if (appSession?.userId != null) return appSession!.userId;

    final authUser =
        _supabase.auth.currentUser ?? _supabase.auth.currentSession?.user;
    if (authUser != null) return authUser.id;

    return null;
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  String? _ownerId(Map<String, dynamic> cart) {
    final product = cart['products'];
    if (product is! Map) return null;

    final ownerId = product['owner_id'];
    if (ownerId == null || ownerId.toString().trim().isEmpty) return null;
    return ownerId.toString();
  }

  Map<String, dynamic>? _firstRpcRow(dynamic result) {
    if (result is List && result.isNotEmpty) {
      return Map<String, dynamic>.from(result.first as Map);
    }
    if (result is Map) return Map<String, dynamic>.from(result);
    return null;
  }

  String _formatTransactionCode(dynamic id) {
    final number = _readInt(id);
    if (number <= 0) return 'ID0000000';
    return 'ID${number.toString().padLeft(7, '0')}';
  }
}

class UserKeranjangException implements Exception {
  const UserKeranjangException(this.message);

  final String message;

  @override
  String toString() => message;
}
