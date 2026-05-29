import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserPesananPage extends StatefulWidget {
  const UserPesananPage({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<UserPesananPage> createState() => _UserPesananPageState();
}

class _UserPesananPageState extends State<UserPesananPage> {
  final supabase = Supabase.instance.client;

  String selectedStatus = 'Semua';

  final List<Map<String, dynamic>> menuStatus = [
    {'title': 'Dipesan', 'icon': Icons.inventory_2_outlined},
    {'title': 'Diambil', 'icon': Icons.local_shipping_outlined},
    {'title': 'Selesai', 'icon': Icons.stars_outlined},
    {'title': 'Semua', 'icon': Icons.all_inbox_outlined},
  ];

  Future<List<Map<String, dynamic>>> getPesanan() async {
    final data = await Supabase.instance.client
        .from('transaksi')
        .select('*, transaksi_item(*)')
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'dipesan':
        return const Color(0xFFFFC107);
      case 'diambil':
        return const Color(0xFFFF9800);
      case 'selesai':
        return const Color(0xFF2E7D32);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F1ED),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: IconButton(
                      onPressed: widget.onBack,
                      icon: const Icon(Icons.arrow_back, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Pesanan Saya',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MENU STATUS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: menuStatus.map((menu) {
                  final isActive = selectedStatus == menu['title'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedStatus = menu['title'];
                      });
                    },
                    child: Column(
                      children: [
                        Icon(
                          menu['icon'],
                          size: 24,
                          color: isActive
                              ? const Color(0xFF2E7D32)
                              : Colors.black87,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          menu['title'],
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: isActive
                                ? const Color(0xFF2E7D32)
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// LIST PESANAN
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: getPesanan(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada pesanan'));
                  }

                  final pesananList = snapshot.data!;

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: pesananList.length,
                    itemBuilder: (context, index) {
                      final item = pesananList[index];

                      final status = item['status_pesanan'] ?? '';
                      final items =
                          item['transaksi_item'] as List<dynamic>? ?? [];

                      final firstItem = items.isNotEmpty ? items[0] : null;

                      final tanggalMulai = firstItem != null
                          ? DateTime.parse(firstItem['tanggal_mulai'])
                          : null;

                      final tanggalSelesai = firstItem != null
                          ? DateTime.parse(firstItem['tanggal_kembali'])
                          : null;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['id_transaksi'].toString(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  Text(item['payment_method'] ?? '-'),

                                  const SizedBox(height: 6),

                                  // ✅ TANGGAL RANGE
                                  Text(
                                    (tanggalMulai != null &&
                                            tanggalSelesai != null)
                                        ? "${DateFormat('d MMM yyyy').format(tanggalMulai)} → ${DateFormat('d MMM yyyy').format(tanggalSelesai)}"
                                        : "-",
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'Rp${NumberFormat('#,###', 'id_ID').format(item['total_harga'])}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF2E7D32),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor(status),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    status,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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
}
