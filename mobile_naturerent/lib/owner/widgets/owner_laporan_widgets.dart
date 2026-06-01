import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/owner_laporan_service.dart';

class OwnerLaporanCard extends StatelessWidget {
  const OwnerLaporanCard({
    super.key,
    required this.monthName,
    required this.isCurrentMonth,
    required this.future,
    required this.animationController,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onRefresh,
  });

  final String monthName;
  final bool isCurrentMonth;
  final Future<LaporanBulan> future;
  final AnimationController animationController;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onRefresh;

  static const _green = Color(0xFF297B2D);

  String _rupiah(double amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(1)}Jt';
    }
    if (amount >= 1000) return 'Rp ${(amount / 1000).toStringAsFixed(0)}Rb';
    return 'Rp ${amount.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _green.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _LaporanHeader(
            monthName: monthName,
            isCurrentMonth: isCurrentMonth,
            onPreviousMonth: onPreviousMonth,
            onNextMonth: onNextMonth,
            onRefresh: onRefresh,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<LaporanBulan>(
              future: future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LaporanSkeleton();
                }
                if (snapshot.hasError) {
                  return _LaporanError(
                    message: snapshot.error.toString(),
                    onRefresh: onRefresh,
                  );
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
        label: 'Pelanggan Bulan Ini',
        value: '${data.pelangganBaru}',
        color: const Color(0xFF2E7D32),
        delay: 0.36,
      ),
    ];

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _LaporanStatTile(
                item: items[0],
                animationController: animationController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LaporanStatTile(
                item: items[1],
                animationController: animationController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LaporanStatTile(
                item: items[2],
                animationController: animationController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _LaporanStatTile(
                item: items[3],
                animationController: animationController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LaporanHeader extends StatelessWidget {
  const _LaporanHeader({
    required this.monthName,
    required this.isCurrentMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onRefresh,
  });

  final String monthName;
  final bool isCurrentMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onRefresh;

  static const _green = Color(0xFF297B2D);
  static const _greenDark = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Container(
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
              color: Colors.white.withValues(alpha: 0.15),
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
                'Laporan Bulanan',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MonthButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: onPreviousMonth,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      monthName,
                      style: GoogleFonts.poppins(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  _MonthButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: isCurrentMonth ? null : onNextMonth,
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
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
    );
  }
}

class _MonthButton extends StatelessWidget {
  const _MonthButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 24,
        height: 24,
        child: Icon(
          icon,
          color: Colors.white.withValues(alpha: enabled ? 0.9 : 0.35),
          size: 20,
        ),
      ),
    );
  }
}

class _LaporanStatTile extends StatelessWidget {
  const _LaporanStatTile({
    required this.item,
    required this.animationController,
  });

  final _Stat item;
  final AnimationController animationController;

  @override
  Widget build(BuildContext context) {
    final anim = CurvedAnimation(
      parent: animationController,
      curve: Interval(
        item.delay,
        item.delay + 0.55,
        curve: Curves.easeOutCubic,
      ),
    );

    return AnimatedBuilder(
      animation: anim,
      builder: (_, _) => Transform.translate(
        offset: Offset(0, 16 * (1 - anim.value)),
        child: Opacity(
          opacity: anim.value.clamp(0.0, 1.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: item.color.withValues(alpha: 0.18)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.13),
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
                    height: 1.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
}

class _LaporanSkeleton extends StatelessWidget {
  const _LaporanSkeleton();

  @override
  Widget build(BuildContext context) {
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
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF297B2D),
        ),
      ),
    ),
  );
}

class _LaporanError extends StatelessWidget {
  const _LaporanError({required this.message, required this.onRefresh});

  final String message;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
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
              color: Color(0xFF212121),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.red),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          TextButton.icon(
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF297B2D),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text('Coba Lagi', style: GoogleFonts.poppins(fontSize: 13)),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}

class _Stat {
  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.delay,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final double delay;
}
