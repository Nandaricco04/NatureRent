import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/owner_home_service.dart';
import 'widgets/owner_home_widgets.dart';

class OwnerHomePage extends StatefulWidget {
  const OwnerHomePage({super.key, required this.ownerId});

  final dynamic ownerId;

  @override
  State<OwnerHomePage> createState() => _OwnerHomePageState();
}

class _OwnerHomePageState extends State<OwnerHomePage> {
  final _homeService = OwnerHomeService();

  bool _loading = true;
  OwnerHomeData _data = OwnerHomeData.empty();
  String? _errorMessage;

  static const _green = Color(0xFF297B2D);
  static const _orange = Color(0xFFE8752A);
  static const _text = Color(0xFF212121);

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  @override
  void didUpdateWidget(covariant OwnerHomePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    if (widget.ownerId == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final data = await _homeService.fetchHomeData(widget.ownerId);
      if (!mounted) return;
      setState(() {
        _data = data;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat ringkasan toko';
        _loading = false;
      });
    }
  }

  String _rupiah(double value) {
    final number = value.round().toString();
    final buffer = StringBuffer();

    for (var i = 0; i < number.length; i++) {
      final reverseIndex = number.length - i;
      buffer.write(number[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) buffer.write('.');
    }

    return 'Rp $buffer';
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _green,
      onRefresh: _loadHomeData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_loading)
              const OwnerHomeLoading()
            else ...[
              if (_errorMessage != null)
                OwnerHomeErrorBanner(message: _errorMessage!),
              Text(
                'Ringkasan Toko',
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 1.58,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  OwnerHomeSummaryCard(
                    icon: Icons.inventory_2_outlined,
                    title: 'Total Alat',
                    value: '${_data.totalAlat}',
                    tint: const Color(0xFFEAF6EC),
                    color: _green,
                  ),
                  OwnerHomeSummaryCard(
                    icon: Icons.receipt_long_outlined,
                    title: 'Pesanan Baru',
                    value: '${_data.pesananBaru}',
                    tint: const Color(0xFFFFF3E8),
                    color: _orange,
                  ),
                  OwnerHomeSummaryCard(
                    icon: Icons.hiking_outlined,
                    title: 'Sedang Disewa',
                    value: '${_data.sedangDisewa}',
                    tint: const Color(0xFFEAF1FF),
                    color: const Color(0xFF2F67B2),
                  ),
                  OwnerHomeSummaryCard(
                    icon: Icons.payments_outlined,
                    title: 'Pendapatan',
                    value: _rupiah(_data.pendapatanBulanIni),
                    tint: const Color(0xFFEFF8F0),
                    color: _green,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              OwnerHomeSectionHeader(
                title: 'Pesanan Terbaru',
                subtitle: '${_data.pesananTerbaru.length} pesanan terakhir',
              ),
              const SizedBox(height: 10),
              if (_data.pesananTerbaru.isEmpty)
                const OwnerHomeEmptyPanel(
                  icon: Icons.receipt_long_outlined,
                  title: 'Belum ada pesanan',
                  subtitle: 'Pesanan terbaru akan tampil di sini.',
                )
              else
                ..._data.pesananTerbaru.map(
                  (order) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: OwnerHomeOrderTile(order: order),
                  ),
                ),
              const SizedBox(height: 12),
              const OwnerHomeSectionHeader(
                title: 'Perlu Perhatian',
                subtitle: 'Hal yang sebaiknya segera dicek',
              ),
              const SizedBox(height: 10),
              OwnerHomeAttentionPanel(
                stockEmpty: _data.stokHabis,
                outOfStockProducts: _data.alatStokHabis,
                pendingOrders: _data.pesananBaru,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
