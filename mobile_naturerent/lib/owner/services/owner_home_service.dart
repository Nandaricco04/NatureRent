import 'package:supabase_flutter/supabase_flutter.dart';

class OwnerHomeData {
  const OwnerHomeData({
    required this.totalAlat,
    required this.pesananBaru,
    required this.sedangDisewa,
    required this.pendapatanBulanIni,
    required this.stokHabis,
    required this.alatStokHabis,
    required this.pesananTerbaru,
  });

  final int totalAlat;
  final int pesananBaru;
  final int sedangDisewa;
  final double pendapatanBulanIni;
  final int stokHabis;
  final List<Map<String, dynamic>> alatStokHabis;
  final List<Map<String, dynamic>> pesananTerbaru;

  factory OwnerHomeData.empty() => const OwnerHomeData(
    totalAlat: 0,
    pesananBaru: 0,
    sedangDisewa: 0,
    pendapatanBulanIni: 0,
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
          .from('transaksi')
          .select(
            'id_transaksi, status, tanggal_mulai, total_harga, jumlah, products!inner(name, owner_id)',
          )
          .eq('products.owner_id', ownerId)
          .order('tanggal_mulai', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  OwnerHomeData _buildData(
    List<Map<String, dynamic>> products,
    List<Map<String, dynamic>> transactions,
  ) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final startOfNextMonth = DateTime(now.year, now.month + 1, 1);

    final monthlyTransactions = transactions.where((transaction) {
      final date = DateTime.tryParse(
        (transaction['tanggal_mulai'] ?? '').toString(),
      );
      if (date == null) return false;
      return !date.isBefore(startOfMonth) && date.isBefore(startOfNextMonth);
    }).toList();

    final outOfStockProducts = products.where((product) {
      return _readInt(product['stock']) <= 0;
    }).toList();

    return OwnerHomeData(
      totalAlat: products.length,
      pesananBaru: transactions.where(_isPendingOrder).length,
      sedangDisewa: transactions.where(_isActiveRental).length,
      pendapatanBulanIni: monthlyTransactions.fold(
        0,
        (sum, row) => sum + ((row['total_harga'] as num?)?.toDouble() ?? 0),
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

  bool _isPendingOrder(Map<String, dynamic> transaction) {
    final status = (transaction['status'] ?? '').toString().toLowerCase();
    return status.contains('menunggu') ||
        status.contains('pending') ||
        status.contains('konfirmasi');
  }

  bool _isActiveRental(Map<String, dynamic> transaction) {
    final status = (transaction['status'] ?? '').toString().toLowerCase();
    return status.contains('disewa') ||
        status.contains('berjalan') ||
        status.contains('aktif');
  }
}
