import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../services/owner_iklan_service.dart';

class OwnerIklanHeader extends StatelessWidget {
  const OwnerIklanHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  static const _text = Color(0xFF1F1F1F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 38,
          height: 38,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 22),
            style: IconButton.styleFrom(backgroundColor: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Iklankan Alat',
              style: GoogleFonts.poppins(
                color: _text,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Jangkau lebih banyak penyewa',
              style: GoogleFonts.poppins(
                color: const Color(0xFF6F6B75),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class OwnerIklanProductSummary extends StatelessWidget {
  const OwnerIklanProductSummary({super.key, required this.product});

  final Map<String, dynamic> product;

  static const _green = Color(0xFF2E6F33);
  static const _orange = Color(0xFFFB8C00);

  @override
  Widget build(BuildContext context) {
    final imageUrl = (product['image_url'] ?? '').toString();
    final name = (product['name'] ?? '-').toString();
    final stock = product['stock'] ?? 0;
    final price = product['price_per_day'] ?? 0;
    final rating = product['rating'] ?? 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 72,
              height: 72,
              color: const Color(0xFFE9F3EA),
              child: imageUrl.isEmpty
                  ? const Icon(Icons.terrain, color: _green)
                  : Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Stok $stock unit',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF83B989),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rp$price/hari',
                  style: GoogleFonts.poppins(
                    color: _green,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F7E7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text(
                  rating.toString(),
                  style: GoogleFonts.poppins(
                    color: _green,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.star, color: _orange, size: 12),
                    Text(
                      'Rating',
                      style: GoogleFonts.poppins(color: _green, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerIklanSectionTitle extends StatelessWidget {
  const OwnerIklanSectionTitle({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFF7E7A75))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: const Color(0xFF9A9792),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFF7E7A75))),
      ],
    );
  }
}

class OwnerIklanPackageCard extends StatelessWidget {
  const OwnerIklanPackageCard({
    super.key,
    required this.package,
    required this.selected,
    required this.currency,
    required this.onTap,
  });

  final IklanPackage package;
  final bool selected;
  final NumberFormat currency;
  final VoidCallback onTap;

  static const _green = Color(0xFF2E6F33);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 136,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF7EC) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? _green : const Color(0xFFE1DDD7),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.16),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              package.durationDays.toString(),
              style: GoogleFonts.poppins(
                color: selected ? _green : const Color(0xFF9A9792),
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'Hari',
              style: GoogleFonts.poppins(
                color: selected ? _green : const Color(0xFF9A9792),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              '${currency.format(package.pricePerDay)}/hr',
              style: GoogleFonts.poppins(
                color: selected ? _green : const Color(0xFF9A9792),
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? _green : const Color(0xFFD5D2CE),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerIklanPaymentDetail extends StatelessWidget {
  const OwnerIklanPaymentDetail({
    super.key,
    required this.package,
    required this.currency,
  });

  final IklanPackage package;
  final NumberFormat currency;

  static const _green = Color(0xFF2E6F33);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rincian Biaya',
            style: GoogleFonts.poppins(
              color: const Color(0xFF8F8B86),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Divider(height: 24),
          _row('Harga Iklan', '${currency.format(package.pricePerDay)} /hari'),
          const SizedBox(height: 10),
          _row('Durasi', '${package.durationDays} hari'),
          const Divider(height: 28),
          _row(
            'Total Bayar',
            currency.format(package.total),
            labelBold: true,
            valueColor: _green,
          ),
        ],
      ),
    );
  }

  Widget _row(
    String label,
    String value, {
    bool labelBold = false,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: labelBold ? Colors.black : const Color(0xFF858293),
            fontSize: 15,
            fontWeight: labelBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.poppins(
            color: valueColor ?? Colors.black,
            fontSize: 15,
            fontWeight: labelBold ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class OwnerIklanQrisChip extends StatelessWidget {
  const OwnerIklanQrisChip({super.key});

  static const _green = Color(0xFF2E6F33);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 168,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFEAF7EC),
          border: Border.all(color: _green, width: 1.5),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.qr_code_scanner, color: _green, size: 24),
            const SizedBox(width: 10),
            Text(
              'QRIS',
              style: GoogleFonts.poppins(
                color: _green,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerIklanQrisBox extends StatelessWidget {
  const OwnerIklanQrisBox({
    super.key,
    required this.total,
    required this.currency,
  });

  final int total;
  final NumberFormat currency;

  static const _green = Color(0xFF2E6F33);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _green, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: _green,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 158,
            height: 158,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE7E1D8), width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset('assets/images/Qris.jpeg', fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),
          Text(
            'Total yang dibayar',
            style: GoogleFonts.poppins(
              color: const Color(0xFF9A9792),
              fontSize: 12,
            ),
          ),
          Text(
            currency.format(total),
            style: GoogleFonts.poppins(
              color: _green,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 258,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EFE8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Column(
              children: const [
                _PaymentStep(
                  number: '1',
                  text: 'Buka aplikasi e-wallet atau\nm-banking',
                ),
                SizedBox(height: 12),
                _PaymentStep(
                  number: '2',
                  text: 'Pilih menu Scan / QRIS, lalu scan kode di atas',
                ),
                SizedBox(height: 12),
                _PaymentStep(
                  number: '3',
                  text: 'Konfirmasi pembayaran',
                ),
                SizedBox(height: 12),
                _PaymentStep(
                  number: '4',
                  text: 'Upload bukti pembayaran di bawah',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({required this.number, required this.text});

  final String number;
  final String text;

  static const _green = Color(0xFF2E6F33);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.black,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerIklanProofPicker extends StatelessWidget {
  const OwnerIklanProofPicker({
    super.key,
    required this.proofUrl,
    required this.uploading,
    required this.onTap,
  });

  final String? proofUrl;
  final bool uploading;
  final VoidCallback onTap;

  static const _green = Color(0xFF2E6F33);

  @override
  Widget build(BuildContext context) {
    final uploaded = proofUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bukti Pembayaran',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: uploading ? null : onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (uploading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: _green,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    uploaded ? Icons.check_circle : Icons.upload_file,
                    color: uploaded ? _green : Colors.black,
                  ),
                const SizedBox(width: 10),
                Text(
                  uploading
                      ? 'Mengupload...'
                      : uploaded
                          ? 'Bukti sudah diupload'
                          : 'Upload File',
                  style: GoogleFonts.poppins(
                    color: uploaded ? _green : Colors.black,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (uploaded) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 132,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D5CF)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                proofUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      'Preview bukti tidak bisa dimuat',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8A8793),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class OwnerIklanEmptyPackages extends StatelessWidget {
  const OwnerIklanEmptyPackages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Paket iklan belum tersedia.',
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(
          color: const Color(0xFF8A8793),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
