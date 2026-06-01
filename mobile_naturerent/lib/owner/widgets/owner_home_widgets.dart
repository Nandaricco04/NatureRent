import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

BoxDecoration ownerHomeCardDecoration() {
  return BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(8),
    boxShadow: const [
      BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2)),
    ],
  );
}

class OwnerHomeLoading extends StatelessWidget {
  const OwnerHomeLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 80),
      child: Center(child: CircularProgressIndicator(color: Color(0xFF297B2D))),
    );
  }
}

class OwnerHomeSummaryCard extends StatelessWidget {
  const OwnerHomeSummaryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.tint,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color tint;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ownerHomeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF212121),
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6D6A66),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OwnerHomeSectionHeader extends StatelessWidget {
  const OwnerHomeSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF212121),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6D6A66),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OwnerHomeOrderTile extends StatelessWidget {
  const OwnerHomeOrderTile({
    super.key,
    required this.order,
    this.onEdit,
    this.onTax,
  });

  final Map<String, dynamic> order;
  final VoidCallback? onEdit;
  final VoidCallback? onTax;

  String get _transactionCode {
    final id = order['id_transaksi'];
    final number = id is num ? id.toInt() : int.tryParse(id.toString()) ?? 0;
    return 'ID${number.toString().padLeft(7, '0')}';
  }

  String get _productNames {
    final items = order['items'];
    if (items is! List) return 'Alat rental';

    final names = items
        .map((item) {
          if (item is! Map) return null;
          return item['nama_produk']?.toString().trim();
        })
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList();

    if (names.isEmpty) return 'Alat rental';
    return names.join(',\n');
  }

  String get _dateText {
    final start = _parseDate(order['tanggal_mulai']);
    final end = _parseDate(order['tanggal_kembali']);
    if (start == null || end == null) return '-';
    return '${_formatDate(start)} - ${_formatDate(end)}';
  }

  String get _status {
    final value = (order['status_pesanan'] ?? '').toString().trim();
    switch (value.toLowerCase()) {
      case 'menunggu_konfirmasi':
      case 'menunggu':
        return 'Menunggu';
      case 'dipesan':
        return 'Dipesan';
      case 'diambil':
        return 'Diambil';
      case 'selesai':
        return 'Selesai';
      case 'dibatalkan':
      case 'batal':
        return 'Dibatalkan';
      default:
        return value.isEmpty ? 'Diproses' : value;
    }
  }

  Color get _statusColor {
    switch (_status.toLowerCase()) {
      case 'menunggu':
      case 'dipesan':
        return const Color(0xFFFFCB31);
      case 'diambil':
        return const Color(0xFFFF9800);
      case 'selesai':
        return const Color(0xFF297B2D);
      case 'dibatalkan':
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFFFFCB31);
    }
  }

  bool get _isCod {
    return (order['payment_method'] ?? '').toString().toLowerCase() == 'cod';
  }

  String get _taxStatus {
    return (order['status_pajak'] ?? 'belum_dibayar')
        .toString()
        .trim()
        .toLowerCase();
  }

  bool get _showTaxAction {
    return _isCod && _isFinished && _taxStatus != 'sudah_dibayar';
  }

  bool get _isTaxWaiting {
    return _taxStatus == 'menunggu_verifikasi';
  }

  String get _taxLabel {
    if (_isTaxWaiting) return 'Menunggu';
    return 'Pajak';
  }

  bool get _isFinished {
    return _status.toLowerCase() == 'selesai';
  }

  bool get _isCancelled {
    return _status.toLowerCase() == 'dibatalkan';
  }

  String get _priceText {
    final value = order['total_harga'] ?? order['owner_subtotal'];
    final number = value is num
        ? value.toInt()
        : int.tryParse(value.toString()) ?? 0;
    final text = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$text';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: ownerHomeCardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _transactionCode,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF297B2D),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _productNames,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF212121),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _dateText,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF6D6A66),
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _priceText,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF297B2D),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: _isFinished && !_showTaxAction
                  ? 100
                  : _isCancelled
                  ? 100
                  : 190,
              child: Row(
                children: [
                  if (_showTaxAction) ...[
                    Expanded(
                      child: _OwnerOrderActionChip(
                        label: _taxLabel,
                        color: Colors.white,
                        textColor: Color(0xFF297B2D),
                        borderColor: Color(0xFF297B2D),
                        onTap: _isTaxWaiting ? null : onTax,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _OwnerOrderActionChip(
                      label: _status,
                      color: _statusColor,
                      textColor: Colors.white,
                    ),
                  ),
                  if (!_isFinished && !_isCancelled) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: _OwnerOrderActionChip(
                        label: 'Edit',
                        color: Colors.white,
                        textColor: Color(0xFF297B2D),
                        borderColor: Color(0xFF297B2D),
                        onTap: onEdit,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _formatDate(DateTime date) {
    const months = [
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

    return '${date.day} ${months[date.month - 1]}';
  }
}

class _OwnerOrderActionChip extends StatelessWidget {
  const _OwnerOrderActionChip({
    required this.label,
    required this.color,
    required this.textColor,
    this.borderColor,
    this.onTap,
  });

  final String label;
  final Color color;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: Container(
          height: 28,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: GoogleFonts.poppins(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class OwnerHomeAttentionPanel extends StatelessWidget {
  const OwnerHomeAttentionPanel({
    super.key,
    required this.stockEmpty,
    required this.outOfStockProducts,
    required this.pendingOrders,
  });

  final int stockEmpty;
  final List<Map<String, dynamic>> outOfStockProducts;
  final int pendingOrders;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];

    if (stockEmpty > 0) {
      items.add(
        OwnerHomeAttentionItem(
          icon: Icons.inventory_2_outlined,
          text: '$stockEmpty alat stok habis',
          details: outOfStockProducts
              .take(3)
              .map(
                (product) => (product['name'] ?? 'Alat tanpa nama').toString(),
              )
              .toList(),
          moreCount: stockEmpty > 3 ? stockEmpty - 3 : 0,
          color: Colors.red,
          tint: const Color(0xFFFFEFEF),
        ),
      );
    }

    if (pendingOrders > 0) {
      items.add(
        OwnerHomeAttentionItem(
          icon: Icons.pending_actions_outlined,
          text: '$pendingOrders pesanan menunggu konfirmasi',
          color: const Color(0xFFE8752A),
          tint: const Color(0xFFFFF3E8),
        ),
      );
    }

    if (items.isEmpty) {
      return const OwnerHomeEmptyPanel(
        icon: Icons.check_circle_outline,
        title: 'Semua aman',
        subtitle: 'Belum ada hal penting yang perlu dicek.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ownerHomeCardDecoration(),
      child: Column(children: items),
    );
  }
}

class OwnerHomeAttentionItem extends StatelessWidget {
  const OwnerHomeAttentionItem({
    super.key,
    required this.icon,
    required this.text,
    this.details = const [],
    this.moreCount = 0,
    required this.color,
    required this.tint,
  });

  final IconData icon;
  final String text;
  final List<String> details;
  final int moreCount;
  final Color color;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF212121),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (details.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  ...details.map(
                    (name) => Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '- $name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6D6A66),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  if (moreCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '+$moreCount alat lainnya',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF6D6A66),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerHomeEmptyPanel extends StatelessWidget {
  const OwnerHomeEmptyPanel({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: ownerHomeCardDecoration(),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF297B2D), size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(
              color: const Color(0xFF212121),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6D6A66),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerHomeErrorBanner extends StatelessWidget {
  const OwnerHomeErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEF),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: GoogleFonts.poppins(
          color: Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
