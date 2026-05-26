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

    final awal = _dateOnly(DateTime(month.year, month.month, 1));
    final akhir = _dateOnly(DateTime(month.year, month.month + 1, 1));

    final items = await _fetchOwnerTransactionItems(
      ownerId: ownerId,
      startDate: awal,
      endDate: akhir,
    );

    final transactionIds = items
        .map((row) => row['transaksi_id']?.toString())
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();
    final customerIds = items
        .map((row) {
          final transaksi = row['transaksi'];
          if (transaksi is! Map) return null;
          return transaksi['user_id']?.toString();
        })
        .whereType<String>()
        .where((id) => id.isNotEmpty)
        .toSet();

    return LaporanBulan(
      totalTransaksi: transactionIds.length,
      pendapatan: items.fold(
        0.0,
        (sum, row) => sum + _readDouble(row['subtotal']),
      ),
      alatDisewa: items.fold(0, (sum, row) => sum + _readInt(row['jumlah'])),
      pelangganBaru: customerIds.length,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchOwnerTransactionItems({
    required dynamic ownerId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final data = await _db
          .from('transaksi_item')
          .select(
            'id_transaksi_item, transaksi_id, jumlah, subtotal, '
            'transaksi!inner(user_id, tanggal_transaksi), '
            'products!inner(owner_id)',
          )
          .eq('products.owner_id', ownerId)
          .gte('transaksi.tanggal_transaksi', startDate)
          .lt('transaksi.tanggal_transaksi', endDate);

      return List<Map<String, dynamic>>.from(data);
    } on PostgrestException catch (e) {
      if (!e.message.toLowerCase().contains('subtotal')) rethrow;

      final data = await _db
          .from('transaksi_item')
          .select(
            'id_transaksi_item, transaksi_id, jumlah, subtotal_sewa, '
            'transaksi!inner(user_id, tanggal_transaksi), '
            'products!inner(owner_id)',
          )
          .eq('products.owner_id', ownerId)
          .gte('transaksi.tanggal_transaksi', startDate)
          .lt('transaksi.tanggal_transaksi', endDate);

      return List<Map<String, dynamic>>.from(data).map((row) {
        return {...row, 'subtotal': row['subtotal_sewa']};
      }).toList();
    }
  }

  String _dateOnly(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }
}
