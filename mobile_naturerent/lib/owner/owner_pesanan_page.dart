import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'owner_edit_pesanan_page.dart';
import 'owner_pajak_page.dart';
import 'widgets/owner_home_widgets.dart';

class OwnerPesananPage extends StatefulWidget {
  const OwnerPesananPage({super.key, required this.ownerId});

  final dynamic ownerId;

  @override
  State<OwnerPesananPage> createState() => _OwnerPesananPageState();
}

class _OwnerPesananPageState extends State<OwnerPesananPage> {
  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _orders = [];

  static const _green = Color(0xFF297B2D);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  @override
  void didUpdateWidget(covariant OwnerPesananPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) {
      _loadOrders();
    }
  }

  Future<void> _loadOrders({bool showLoading = true}) async {
    if (showLoading) {
      setState(() {
        _loading = true;
        _errorMessage = null;
      });
    }

    try {
      final orders = await _fetchOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
        _loading = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = 'Gagal memuat pesanan: $e';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchOrders() async {
    if (widget.ownerId == null) return [];

    final data = await Supabase.instance.client
        .from('transaksi_item')
        .select(
          'id_transaksi_item, transaksi_id, product_id, nama_produk, tanggal_mulai, tanggal_kembali, subtotal, '
          'transaksi!inner(id_transaksi, payment_method, status_pesanan, total_harga, pajak, bukti_pembayaran, bukti_pajak, status_pajak, created_at), '
          'products!inner(owner_id)',
        )
        .eq('products.owner_id', widget.ownerId)
        .order('id_transaksi_item', ascending: false);

    return _groupOrders(List<Map<String, dynamic>>.from(data));
  }

  List<Map<String, dynamic>> _groupOrders(List<Map<String, dynamic>> rows) {
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
          'owner_subtotal': 0,
          'bukti_pembayaran': transaksi['bukti_pembayaran'],
          'bukti_pajak': transaksi['bukti_pajak'],
          'status_pajak': transaksi['status_pajak'],
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

  double _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse((value ?? '0').toString()) ?? 0;
  }

  Future<void> _refresh() async {
    await _loadOrders(showLoading: false);
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _green,
      onRefresh: _refresh,
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: _green));
    }

    if (_errorMessage != null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        children: [OwnerHomeErrorBanner(message: _errorMessage!)],
      );
    }

    if (_orders.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 140, left: 24, right: 24),
        children: [
          const Icon(Icons.receipt_long_outlined, size: 52, color: _green),
          const SizedBox(height: 14),
          Text(
            'Pesanan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF212121),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Daftar pesanan rental akan tampil di sini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6D6A66),
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      itemCount: _orders.length,
      itemBuilder: (context, index) {
        final order = _orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: OwnerHomeOrderTile(
            key: ValueKey(
              '${order['id_transaksi']}-${order['status_pesanan']}-${order['status_pajak']}-${order['bukti_pajak']}',
            ),
            order: order,
            onEdit: () => _openEditOrder(order),
            onTax: () => _openTaxOrder(order),
          ),
        );
      },
    );
  }

  Future<void> _openEditOrder(Map<String, dynamic> order) async {
    final changed = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => OwnerEditPesananPage(order: order)),
    );

    if (!mounted) return;

    if (changed is Map) {
      final updatedStatus = changed['status_pesanan'];
      if (updatedStatus != null) {
        setState(() {
          order['status_pesanan'] = updatedStatus;
        });
      }
      _loadOrders(showLoading: false);
      return;
    }

    if (changed == true) {
      _loadOrders(showLoading: false);
    }
  }

  Future<void> _openTaxOrder(Map<String, dynamic> order) async {
    final changed = await Navigator.push<dynamic>(
      context,
      MaterialPageRoute(builder: (_) => OwnerPajakPage(order: order)),
    );

    if (!mounted) return;
    if (changed is Map) {
      setState(() {
        order['bukti_pajak'] = changed['bukti_pajak'];
        order['status_pajak'] = changed['status_pajak'];
      });
      _loadOrders(showLoading: false);
      return;
    }

    if (changed == true) {
      _loadOrders(showLoading: false);
    }
  }
}
