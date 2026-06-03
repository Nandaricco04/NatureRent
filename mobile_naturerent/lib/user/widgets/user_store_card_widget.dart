import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UserStoreCardWidget extends StatelessWidget {
  const UserStoreCardWidget({
    super.key,
    required this.owner,
    required this.ratingRataRata,
  });

  final Map<String, dynamic> owner;
  final double ratingRataRata;

  @override
  Widget build(BuildContext context) {
    final namaKota = owner['lokasi']?['nama_kota'] ?? '';
    final jamOps = (owner['jam_operasional'] ?? '').toString();
    final telepon = (owner['nomor_telepon'] ?? '').toString();
    final fotoUrl = (owner['foto_profil'] ?? '').toString();
    final alamat = (owner['alamat'] ?? '').toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              color: const Color(0xFFE9F3EA),
              child: fotoUrl.isEmpty
                  ? const Icon(
                      Icons.storefront,
                      size: 40,
                      color: Color(0xFF297B2D),
                    )
                  : Image.network(
                      fotoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.storefront,
                        size: 40,
                        color: Color(0xFF297B2D),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (owner['nama_toko'] ?? '').toString(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1B1B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFE8752A), size: 16),
                    const SizedBox(width: 4),
                    Text(
                      ratingRataRata <= 0
                          ? '-'
                          : ratingRataRata.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (namaKota.isNotEmpty)
                  _infoRow(Icons.location_on_rounded, namaKota),
                if (jamOps.isNotEmpty)
                  _infoRow(Icons.access_time_rounded, 'Buka: $jamOps'),
                if (telepon.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: telepon));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nomor telepon disalin')),
                      );
                    },
                    child: _infoRow(Icons.phone_rounded, telepon),
                  ),
                if (alamat.isNotEmpty)
                  _infoRow(Icons.map_outlined, alamat, maxLines: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF297B2D)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              text,
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6D6A66),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
