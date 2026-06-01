import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerHomeData {
  const OwnerHomeData({
    required this.totalAlat,
    required this.pesananBaru,
    required this.sedangDisewa,
    required this.pendapatanHariIni,
    required this.stokHabis,
    required this.alatStokHabis,
    required this.pesananTerbaru,
  });

  final int totalAlat;
  final int pesananBaru;
  final int sedangDisewa;
  final double pendapatanHariIni;
  final int stokHabis;
  final List<Map<String, dynamic>> alatStokHabis;
  final List<Map<String, dynamic>> pesananTerbaru;

  factory OwnerHomeData.empty() => const OwnerHomeData(
    totalAlat: 0,
    pesananBaru: 0,
    sedangDisewa: 0,
    pendapatanHariIni: 0,
    stokHabis: 0,
    alatStokHabis: [],
    pesananTerbaru: [],
  );
}

class OwnerHomeService {
  OwnerHomeService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<OwnerHomeData> fetchHomeData(dynamic ownerId) async {
    if (ownerId == null) return OwnerHomeData.empty();

    final products = await _fetchProducts(ownerId);
    final transactions = await _fetchTransactions(ownerId);

    return _buildData(products, transactions);
  }

  Future<List<Map<String, dynamic>>> _fetchProducts(dynamic ownerId) async {
    final data = await _supabase
        .from('products')
        .select('id_product, name, stock')
        .eq('owner_id', ownerId);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<List<Map<String, dynamic>>> _fetchTransactions(dynamic ownerId) async {
    try {
      final data = await _supabase
          .from('transaksi_item')
          .select(
            'id_transaksi_item, transaksi_id, product_id, nama_produk, tanggal_mulai, tanggal_kembali, subtotal, '
            'transaksi!inner(id_transaksi, payment_method, status_pesanan, total_harga, pajak, bukti_pembayaran, bukti_pajak, status_pajak, created_at), '
            'products!inner(owner_id)',
          )
          .eq('products.owner_id', ownerId)
          .order('id_transaksi_item', ascending: false)
          .limit(20);

      return _buildLatestOrders(List<Map<String, dynamic>>.from(data));
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _buildLatestOrders(
    List<Map<String, dynamic>> rows,
  ) {
    final grouped = <String, Map<String, dynamic>>{};

    for (final row in rows) {
      final transaksi = row['transaksi'];
      if (transaksi is! Map) continue;

      final id = (transaksi['id_transaksi'] ?? row['transaksi_id']).toString();
      final order = grouped.putIfAbsent(id, () {
        return {
          'id_transaksi': transaksi['id_transaksi'] ?? row['transaksi_id'],
          'payment_method': transaksi['payment_method'],
          'status_pesanan': transaksi['status_pesanan'],
          'total_harga': transaksi['total_harga'],
          'pajak': transaksi['pajak'],
          'bukti_pembayaran': transaksi['bukti_pembayaran'],
          'bukti_pajak': transaksi['bukti_pajak'],
          'status_pajak': transaksi['status_pajak'],
          'owner_subtotal': 0,
          'created_at': transaksi['created_at'],
          'tanggal_mulai': row['tanggal_mulai'],
          'tanggal_kembali': row['tanggal_kembali'],
          'items': <Map<String, dynamic>>[],
        };
      });

      (order['items'] as List<Map<String, dynamic>>).add({
        'nama_produk': row['nama_produk'],
        'tanggal_mulai': row['tanggal_mulai'],
        'tanggal_kembali': row['tanggal_kembali'],
        'subtotal': row['subtotal'],
      });
      order['owner_subtotal'] =
          _readDouble(order['owner_subtotal']) + _readDouble(row['subtotal']);
    }

    return grouped.values.toList()..sort((a, b) {
      final aDate = DateTime.tryParse((a['created_at'] ?? '').toString());
      final bDate = DateTime.tryParse((b['created_at'] ?? '').toString());
      if (aDate == null || bDate == null) return 0;
      return bDate.compareTo(aDate);
    });
  }

  OwnerHomeData _buildData(
    List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final startOfTomorrow = startOfToday.add(const Duration(days: 1));

    final todayTransactions = transactions.where((transaction) {
      if (_isCancelledOrder(transaction)) return false;

      final date = DateTime.tryParse(
        (transaction['created_at'] ?? transaction['tanggal_mulai'] ?? '')
            .toString(),
      );
      if (date == null) return false;
      return !date.isBefore(startOfToday) && date.isBefore(startOfTomorrow);
    }).toList();

    final outOfStockProducts = products.where((product) {
      return _readInt(product['stock']) <= 0;
    }).toList();

    return OwnerHomeData(
      totalAlat: products.length,
      pesananBaru: transactions.where(_isPendingOrder).length,
      sedangDisewa: transactions.where(_isActiveRental).length,
      pendapatanHariIni: todayTransactions.fold(
        0,
        (sum, row) => sum + _readDouble(row['owner_subtotal']),
      ),
      stokHabis: outOfStockProducts.length,
      alatStokHabis: outOfStockProducts,
      pesananTerbaru: transactions.take(3).toList(),
    );
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }

  String _normalizedStatus(Map<String, dynamic> transaction) {
    return (transaction['status_pesanan'] ?? '')
        .toString()
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[\s-]+'), '_');
  }

  bool _isCancelledOrder(Map<String, dynamic> transaction) {
    final status = _normalizedStatus(transaction);
    return status == 'dibatalkan' || status == 'batal';
  }

  bool _isPendingOrder(Map<String, dynamic> transaction) {
    final status = _normalizedStatus(transaction);
    return status.contains('menunggu') ||
        status.contains('pending') ||
        status.contains('konfirmasi') ||
        status == 'dipesan';
  }

  bool _isActiveRental(Map<String, dynamic> transaction) {
    final status = _normalizedStatus(transaction);
    return status == 'diambil' ||
        status.contains('disewa') ||
        status.contains('berjalan') ||
        status.contains('aktif');
  }
}
