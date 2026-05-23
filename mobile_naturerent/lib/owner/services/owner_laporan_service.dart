import 'package:supabase_flutter/supabase_flutter.dart';

class LaporanBulan {
  final int totalTransaksi;
  final double pendapatan;
  final int alatDisewa;
  final int pelangganBaru;

  const LaporanBulan({
    required this.totalTransaksi,
    required this.pendapatan,
    required this.alatDisewa,
    required this.pelangganBaru,
  });

  factory LaporanBulan.empty() => const LaporanBulan(
    totalTransaksi: 0,
    pendapatan: 0,
    alatDisewa: 0,
    pelangganBaru: 0,
  );
}

class LaporanService {
  LaporanService({SupabaseClient? client})
    : _db = client ?? Supabase.instance.client;

  final SupabaseClient _db;

  Future<LaporanBulan> getLaporanBulan(DateTime month, dynamic ownerId) async {
    if (ownerId == null) return LaporanBulan.empty();

    final awal = DateTime(month.year, month.month, 1).toIso8601String();
    final akhir = DateTime(month.year, month.month + 1, 1).toIso8601String();

    final transaksiRes = await _db
        .from('transaksi')
        .select(
          'id_transaksi, user_id, total_harga, jumlah, products!inner(owner_id)',
        )
        .eq('products.owner_id', ownerId)
        .gte('tanggal_mulai', awal)
        .lt('tanggal_mulai', akhir);

    final transactions = List<Map<String, dynamic>>.from(transaksiRes);
    final customerIds = transactions
        .map((row) => row['user_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    return LaporanBulan(
      totalTransaksi: transactions.length,
      pendapatan: transactions.fold(
        0.0,
        (sum, row) => sum + ((row['total_harga'] as num?)?.toDouble() ?? 0),
      ),
      alatDisewa: transactions.fold(
        0,
        (sum, row) => sum + ((row['jumlah'] as num?)?.toInt() ?? 0),
      ),
      pelangganBaru: customerIds.length,
    );
  }
}
