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
  const OwnerHomeOrderTile({super.key, required this.order});

  final Map<String, dynamic> order;

  String get _productName {
    final product = order['products'];
    if (product is Map && product['name'] != null) {
      return product['name'].toString();
    }
    return 'Alat rental';
  }

  String get _dateText {
    final date = DateTime.tryParse((order['tanggal_mulai'] ?? '').toString());
    if (date == null) return '-';
    return '${date.day}/${date.month}/${date.year}';
  }

  String get _status {
    final value = (order['status'] ?? '').toString().trim();
    return value.isEmpty ? 'Diproses' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: ownerHomeCardDecoration(),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF6EC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              color: Color(0xFF297B2D),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF212121),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mulai $_dateText',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6D6A66),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              _status,
              style: GoogleFonts.poppins(
                color: const Color(0xFFE8752A),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
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
