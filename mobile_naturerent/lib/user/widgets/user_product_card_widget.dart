import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../user_detail_alat.dart';

class UserProductCardWidget extends StatelessWidget {
  const UserProductCardWidget({
    super.key,
    required this.product,
    required this.namaToko,
  });

  final Map<String, dynamic> product;
  final String namaToko;

  String _formatRp(num value) => NumberFormat.currency(
        locale: 'id',
        symbol: 'Rp',
        decimalDigits: 0,
      ).format(value);

  @override
  Widget build(BuildContext context) {
    final imageUrl = (product['image_url'] ?? '').toString();
    final nama = (product['name'] ?? '').toString();
    final harga = ((product['price_per_day'] ?? 0) as num).toDouble();
    final rating = ((product['rating'] ?? 0) as num).toDouble();
    final advertised =
        product['iklan'] == true ||
        (product['iklan'] ?? '').toString().toLowerCase() == 'true' ||
        product['advertised'] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => UserDetailAlat(productId: product['id_product'].toString()),
          ),
        );
      },
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      color: const Color(0xFFEAF6EC),
                      child: imageUrl.isEmpty
                          ? const Icon(
                              Icons.terrain,
                              color: Color(0xFF297B2D),
                              size: 44,
                            )
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.terrain,
                                color: Color(0xFF297B2D),
                                size: 44,
                              ),
                            ),
                    ),
                  ),
                  if (advertised)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF297B2D),
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'Iklan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    namaToko,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 8, color: Color(0xFF6D6A66)),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Color(0xFF297B2D),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                            children: [
                              TextSpan(text: _formatRp(harga)),
                              const TextSpan(
                                text: '\n/hari',
                                style: TextStyle(
                                  color: Color(0xFF6D6A66),
                                  fontSize: 8,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Icon(Icons.star, color: Color(0xFFE8752A), size: 16),
                      const SizedBox(width: 2),
                      Text(
                        rating <= 0 ? '-' : rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF212121),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
