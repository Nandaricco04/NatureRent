import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'user_pesanan_widgets.dart';

class UserReviewHeader extends StatelessWidget {
  const UserReviewHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Review Alat',
          style: TextStyle(
            color: Color(0xFF242424),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class UserReviewProductCard extends StatelessWidget {
  const UserReviewProductCard({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final product = item['products'] is Map ? item['products'] as Map : null;
    final imageUrl = (product?['image_url'] ?? '').toString();
    final productName =
        (item['nama_produk'] ?? product?['name'] ?? 'Alat outdoor').toString();
    final ownerData = product?['owner'];
    final owner = ownerData is Map ? ownerData : null;
    final storeName = (owner?['nama_toko'] ?? 'NatureRent').toString();
    final price = item['harga_per_hari'] ?? product?['price_per_day'] ?? 0;

    return Container(
      height: 106,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x17000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 82,
              height: 82,
              color: const Color(0xFFEAF6EC),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.terrain, color: userPesananGreen, size: 34)
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.terrain,
                        color: userPesananGreen,
                        size: 34,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF242424),
                    fontSize: 14,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  storeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF6D6A66),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  _formatRp(price),
                  style: const TextStyle(
                    color: userPesananGreen,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatRp(dynamic value) {
    final number = value is num
        ? value
        : num.tryParse((value ?? '0').toString()) ?? 0;
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(number);
  }
}

class UserReviewSectionTitle extends StatelessWidget {
  const UserReviewSectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF242424),
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: Color(0xFF7B7770),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class UserReviewRatingPicker extends StatelessWidget {
  const UserReviewRatingPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  static const _labels = [
    'Sangat Buruk',
    'Buruk',
    'Cukup',
    'Baik',
    'Sangat Baik',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(5, (index) {
          final starValue = index + 1;
          final isActive = value >= starValue;

          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => onChanged(starValue),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star,
                    size: 28,
                    color: isActive
                        ? const Color(0xFFFF8A00)
                        : const Color(0xFFD9D9D9),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _labels[index],
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class UserReviewCommentBox extends StatelessWidget {
  const UserReviewCommentBox({super.key, required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 6,
      maxLines: 6,
      textAlignVertical: TextAlignVertical.top,
      decoration: InputDecoration(
        hintText: 'Tulis komentarmu disini',
        hintStyle: const TextStyle(
          color: Color(0xFF7B7770),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: userPesananGreen),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(7),
          borderSide: const BorderSide(color: userPesananGreen, width: 1.4),
        ),
      ),
      style: const TextStyle(fontSize: 12, color: Color(0xFF242424)),
    );
  }
}

class UserReviewPrimaryButton extends StatelessWidget {
  const UserReviewPrimaryButton({
    super.key,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: enabled ? onTap : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: userPesananGreen,
          disabledBackgroundColor: const Color(0xFF9DB89F),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}

class UserReviewSecondaryButton extends StatelessWidget {
  const UserReviewSecondaryButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF242424),
          side: const BorderSide(color: Color(0xFF242424)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: const Text(
          'Batalkan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
