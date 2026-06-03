import 'package:flutter/material.dart';

const userPesananGreen = Color(0xFF2E7D32);
const userPesananBackground = Color(0xFFF3F1ED);

const userPesananStatusMenus = [
  {'title': 'Dipesan', 'icon': Icons.inventory_2_outlined},
  {'title': 'Diambil', 'icon': Icons.local_shipping_outlined},
  {'title': 'Selesai', 'icon': Icons.stars_outlined},
  {'title': 'Semua', 'icon': Icons.all_inbox_outlined},
];

class UserPesananHeader extends StatelessWidget {
  const UserPesananHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
              onPressed: onBack,
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
    );
  }
}

class UserPesananStatusMenu extends StatelessWidget {
  const UserPesananStatusMenu({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  final String selectedStatus;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: userPesananStatusMenus.map((menu) {
          final title = menu['title'].toString();
          final isActive = selectedStatus == title;

          return GestureDetector(
            onTap: () => onChanged(title),
            child: Column(
              children: [
                Icon(
                  menu['icon'] as IconData,
                  size: 24,
                  color: isActive ? userPesananGreen : Colors.black87,
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    color: isActive ? userPesananGreen : Colors.black87,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class UserPesananOrderCard extends StatelessWidget {
  const UserPesananOrderCard({
    super.key,
    required this.order,
    this.onCancel,
    this.onReview,
  });

  final Map<String, dynamic> order;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final status = (order['status_pesanan'] ?? '').toString();
    final items = order['transaksi_item'] as List<dynamic>? ?? [];
    final firstItem = items.isNotEmpty ? items[0] : null;
    final tanggalMulai = _parseDate(firstItem?['tanggal_mulai']);
    final tanggalSelesai = _parseDate(firstItem?['tanggal_kembali']);
    final canReview = items.any((item) => item is Map && !hasReview(item));

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      height: 166,
      padding: const EdgeInsets.fromLTRB(18, 18, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
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
                      transactionCode(order['id_transaksi']),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: userPesananGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      productNames(items),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF242424),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dateRange(tanggalMulai, tanggalSelesai),
                      style: const TextStyle(
                        color: Color(0xFF6D6A66),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 108,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    formatRp(order['total_harga']),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: userPesananGreen,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Align(
            alignment: Alignment.centerRight,
            child: UserPesananStatusActions(
              status: status,
              onCancel: onCancel,
              onReview: canReview ? onReview : null,
            ),
          ),
        ],
      ),
    );
  }
}

class UserPesananStatusActions extends StatelessWidget {
  const UserPesananStatusActions({
    super.key,
    required this.status,
    this.onCancel,
    this.onReview,
  });

  final String status;
  final VoidCallback? onCancel;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final label = statusLabel(status);
    final canCancel = canCancelStatus(status);

    if (canCancel) {
      return SizedBox(
        width: 196,
        child: Row(
          children: [
            Expanded(
              child: UserPesananActionChip(
                label: 'Batalkan',
                color: Colors.white,
                textColor: Color(0xFFD32F2F),
                borderColor: Color(0xFFD32F2F),
                onTap: onCancel,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: UserPesananActionChip(
                label: label,
                color: statusColor(status),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    if (isFinishedStatus(status) && onReview != null) {
      return SizedBox(
        width: 196,
        child: Row(
          children: [
            Expanded(
              child: UserPesananActionChip(
                label: 'Review',
                color: Colors.white,
                textColor: userPesananGreen,
                borderColor: userPesananGreen,
                onTap: onReview,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: UserPesananActionChip(
                label: label,
                color: statusColor(status),
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: 120,
      child: UserPesananActionChip(
        label: label,
        color: statusColor(status),
        textColor: Colors.white,
      ),
    );
  }
}

class UserPesananReviewItemTile extends StatelessWidget {
  const UserPesananReviewItemTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final product = item['products'] is Map ? item['products'] as Map : null;
    final imageUrl = (product?['image_url'] ?? '').toString();
    final productName =
        (item['nama_produk'] ?? product?['name'] ?? 'Alat outdoor').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Container(
            width: 52,
            height: 52,
            color: const Color(0xFFEAF6EC),
            child: imageUrl.isEmpty
                ? const Icon(Icons.terrain, color: userPesananGreen)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.terrain, color: userPesananGreen),
                  ),
          ),
        ),
        title: Text(
          productName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
        ),
        subtitle: Text(
          formatRp(item['harga_per_hari']),
          style: const TextStyle(
            color: userPesananGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: userPesananGreen),
        onTap: onTap,
      ),
    );
  }
}

class UserPesananActionChip extends StatelessWidget {
  const UserPesananActionChip({
    super.key,
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
        borderRadius: BorderRadius.circular(7),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(7),
            border: borderColor == null
                ? null
                : Border.all(color: borderColor!),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

bool canCancelStatus(String status) {
  final value = status.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  return value == 'menunggu_konfirmasi' ||
      value == 'menunggu' ||
      value == 'dipesan';
}

bool isFinishedStatus(String status) {
  final value = status.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
  return value == 'selesai';
}

bool hasReview(Map<dynamic, dynamic> item) {
  final reviews = item['reviews'];
  if (reviews is List) return reviews.isNotEmpty;
  if (reviews is Map) return reviews.isNotEmpty;
  return false;
}

Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'menunggu_konfirmasi':
    case 'menunggu':
      return const Color(0xFFFFCB31);
    case 'dipesan':
      return const Color(0xFFFFC107);
    case 'diambil':
      return const Color(0xFFFF9800);
    case 'selesai':
      return userPesananGreen;
    case 'dibatalkan':
    case 'batal':
      return const Color(0xFFD32F2F);
    default:
      return Colors.grey;
  }
}

String statusLabel(String status) {
  switch (status.toLowerCase()) {
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
      return status.isEmpty ? '-' : status;
  }
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String transactionCode(dynamic id) {
  final number = id is num ? id.toInt() : int.tryParse(id.toString()) ?? 0;
  return 'ID${number.toString().padLeft(7, '0')}';
}

String productNames(List<dynamic> items) {
  final names = items
      .map((item) {
        if (item is! Map) return null;
        return item['nama_produk']?.toString().trim();
      })
      .where((name) => name != null && name.isNotEmpty)
      .cast<String>()
      .toList();

  if (names.isEmpty) return 'Alat outdoor';
  return names.join(',\n');
}

String dateRange(DateTime? start, DateTime? end) {
  if (start == null || end == null) return '-';
  return '${formatDate(start)} - ${formatDate(end)}';
}

String formatDate(DateTime date) {
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

String formatRp(dynamic value) {
  final number = value is num
      ? value.toInt()
      : int.tryParse(value.toString()) ?? 0;
  final text = number.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
    (match) => '${match[1]}.',
  );
  return 'Rp$text';
}
