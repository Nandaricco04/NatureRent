import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../widgets/app_alerts.dart';
import 'services/user_pesanan_service.dart';
import 'user_review_alat_page.dart';
import 'widgets/user_pesanan_widgets.dart';

class UserPesananPage extends StatefulWidget {
  const UserPesananPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<UserPesananPage> createState() => _UserPesananPageState();
}

class _UserPesananPageState extends State<UserPesananPage> {
  final _service = UserPesananService();

  String selectedStatus = 'Semua';
  RealtimeChannel? _ordersChannel;

  Future<List<Map<String, dynamic>>> getPesanan() {
    return _service.fetchPesanan();
  }

  @override
  void initState() {
    super.initState();
    _listenOrderChanges();
  }

  @override
  void dispose() {
    if (_ordersChannel != null) {
      Supabase.instance.client.removeChannel(_ordersChannel!);
    }
    super.dispose();
  }

  void _listenOrderChanges() {
    _ordersChannel = Supabase.instance.client
        .channel('user_pesanan_status_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'transaksi',
          callback: (_) {
            if (mounted) setState(() {});
          },
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userPesananBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            UserPesananHeader(onBack: widget.onBack),
            const SizedBox(height: 20),
            UserPesananStatusMenu(
              selectedStatus: selectedStatus,
              onChanged: (value) => setState(() => selectedStatus = value),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getPesanan(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Gagal memuat pesanan: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final pesananList = snapshot.data ?? [];
                  if (pesananList.isEmpty) {
                    return const Center(child: Text('Belum ada pesanan'));
                  }

                  final filteredPesanan = _filterPesanan(pesananList);
                  if (filteredPesanan.isEmpty) {
                    return const Center(child: Text('Belum ada pesanan'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredPesanan.length,
                    itemBuilder: (context, index) {
                      return UserPesananOrderCard(
                        order: filteredPesanan[index],
                        onCancel: () =>
                            _confirmCancelPesanan(filteredPesanan[index]),
                        onReview: () =>
                            _showReviewItems(filteredPesanan[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterPesanan(
    List<Map<String, dynamic>> pesananList,
  ) {
    return pesananList.where((item) {
      if (selectedStatus == 'Semua') return true;
      return statusLabel((item['status_pesanan'] ?? '').toString()) ==
          selectedStatus;
    }).toList();
  }

  Future<void> _showReviewItems(Map<String, dynamic> order) async {
    final items = order['transaksi_item'] as List<dynamic>? ?? [];
    final reviewableItems = items.where((item) {
      if (item is! Map) return false;
      return !hasReview(item);
    }).toList();

    if (reviewableItems.isEmpty) {
      AppAlerts.showSnackBar(
        context,
        message: 'Semua alat sudah direview',
        subtitle: 'Tidak ada item lain yang perlu diberi ulasan.',
        type: AppAlertType.info,
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: userPesananBackground,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7D2CB),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Pilih Alat',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Review diberikan per alat yang selesai disewa',
                  style: TextStyle(color: Color(0xFF6D6A66), fontSize: 12),
                ),
                const SizedBox(height: 14),
                ...reviewableItems.map((item) {
                  if (item is! Map) return const SizedBox.shrink();
                  final normalizedItem = Map<String, dynamic>.from(item);
                  return UserPesananReviewItemTile(
                    item: normalizedItem,
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      final reviewed = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => UserReviewAlatPage(
                            order: order,
                            item: normalizedItem,
                          ),
                        ),
                      );
                      if (reviewed == true && mounted) setState(() {});
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmCancelPesanan(Map<String, dynamic> order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          title: const Text(
            'Batalkan pesanan?',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Yakin ingin membatalkan pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Tidak',
                style: TextStyle(color: userPesananGreen),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      final updated = await _service.cancelPesanan(order['id_transaksi']);
      if (!mounted) return;
      setState(() {
        order['status_pesanan'] = updated['status_pesanan'];
      });
      AppAlerts.showSnackBar(
        context,
        message: 'Pesanan berhasil dibatalkan',
        subtitle: 'Status pesanan sudah diperbarui.',
        type: AppAlertType.success,
      );
    } catch (e) {
      if (!mounted) return;
      AppAlerts.showSnackBar(
        context,
        message: 'Gagal membatalkan pesanan',
        subtitle: e.toString(),
        type: AppAlertType.error,
      );
    }
  }
}
