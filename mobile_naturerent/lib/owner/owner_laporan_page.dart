import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
  final _db = Supabase.instance.client;

  Future<LaporanBulan> getLaporanBulanIni() async {
    final now = DateTime.now();
    final awal = DateTime(now.year, now.month, 1).toIso8601String();
    final akhir = DateTime(now.year, now.month + 1, 1).toIso8601String();

    final transaksiRes = await _db
        .from('transaksi')
        .select('id_transaksi')
        .gte('tanggal_mulai', awal)
        .lt('tanggal_mulai', akhir);

    final pendapatanRes = await _db
        .from('transaksi')
        .select('total_harga')
        .gte('tanggal_mulai', awal)
        .lt('tanggal_mulai', akhir);

    final sewaRes = await _db
        .from('transaksi')
        .select('jumlah')
        .gte('tanggal_mulai', awal)
        .lt('tanggal_mulai', akhir);

    // final userRes = await _db
    //     .from('users')
    //     .select('id_user')
    //     .gte('created_at', awal)
    //     .lt('created_at', akhir);

    final userRes = await _db
        .from('users')
        .select('id_user')
        .eq('role', 'user')
        .gte('created_at', awal)
        .lt('created_at', akhir);

    return LaporanBulan(
      totalTransaksi: (transaksiRes as List).length,

      pendapatan: (pendapatanRes as List).fold(
        0.0,
        (sum, row) => sum + ((row['total_harga'] as num?)?.toDouble() ?? 0),
      ),

      alatDisewa: (sewaRes as List).fold(
        0,
        (sum, row) => sum + ((row['jumlah'] as num?)?.toInt() ?? 0),
      ),

      pelangganBaru: (userRes as List).length,
    );
  }
}

class OwnerLaporanPage extends StatefulWidget {
  const OwnerLaporanPage({super.key});

  @override
  State<OwnerLaporanPage> createState() => _OwnerLaporanPageState();
}

class _OwnerLaporanPageState extends State<OwnerLaporanPage>
    with SingleTickerProviderStateMixin {
  final _service = LaporanService();
  late Future<LaporanBulan> _future;
  late AnimationController _animCtrl;

  static const _green = Color(0xFF297B2D);
  static const _greenDark = Color(0xFF1B5E20);
  static const _text = Color(0xFF212121);

  final _bulanList = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String get _namaBulan {
    final now = DateTime.now();
    return '${_bulanList[now.month - 1]} ${now.year}';
  }

  String _rupiah(double amount) {
    if (amount >= 1000000)
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    _future = _service.getLaporanBulanIni();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    _animCtrl.forward(from: 0);
    setState(() => _future = _service.getLaporanBulanIni());
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: _green,
      onRefresh: () async => _refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: _buildLaporanCard(),
      ),
    );
  }

  Widget _buildLaporanCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header hijau gradient
          Container(
            padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_greenDark, _green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Laporan Bulan Ini',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _namaBulan,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withOpacity(0.75),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: _refresh,
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Grid stat cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<LaporanBulan>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildSkeleton();
                }
                if (snapshot.hasError) {
                  return _buildError(snapshot.error.toString());
                }
                final data = snapshot.data ?? LaporanBulan.empty();
                return _buildGrid(data);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(LaporanBulan data) {
    final items = [
      _Stat(
        icon: Icons.receipt_long_rounded,
        label: 'Total Transaksi',
        value: '${data.totalTransaksi}',
        color: _green,
        delay: 0.0,
      ),
      _Stat(
        icon: Icons.payments_rounded,
        label: 'Pendapatan',
        value: _rupiah(data.pendapatan),
        color: const Color(0xFF00796B),
        delay: 0.12,
      ),
      _Stat(
        icon: Icons.inventory_2_rounded,
        label: 'Alat Disewa',
        value: '${data.alatDisewa} Unit',
        color: const Color(0xFF558B2F),
        delay: 0.24,
      ),
      _Stat(
        icon: Icons.person_add_rounded,
        label: 'Pelanggan Baru',
        value: '${data.pelangganBaru}',
        color: const Color(0xFF2E7D32),
        delay: 0.36,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _tile(items[0])),
            const SizedBox(width: 12),
            Expanded(child: _tile(items[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _tile(items[2])),
            const SizedBox(width: 12),
            Expanded(child: _tile(items[3])),
          ],
        ),
      ],
    );
  }

  Widget _tile(_Stat item) {
    final anim = CurvedAnimation(
      parent: _animCtrl,
      curve: Interval(
        item.delay,
        item.delay + 0.55,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, 16 * (1 - anim.value)),
        child: Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withOpacity(0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item.icon, color: item.color, size: 18),
                ),
                const SizedBox(height: 14),
                Text(
                  item.value,
                  style: GoogleFonts.poppins(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: item.color,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: const Color(0xFF888888),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _skeletonBox()),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _skeletonBox()),
            const SizedBox(width: 12),
            Expanded(child: _skeletonBox()),
          ],
        ),
      ],
    );
  }

  Widget _skeletonBox() => Container(
    height: 108,
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Center(
      child: SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2, color: _green),
      ),
    ),
  );

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3F3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: Colors.red, size: 34),
          const SizedBox(height: 8),
          Text(
            'Gagal memuat data',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _text,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            msg,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.red),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('Coba Lagi', style: GoogleFonts.poppins(fontSize: 13)),
            onPressed: _refresh,
          ),
        ],
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double delay;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });
}
