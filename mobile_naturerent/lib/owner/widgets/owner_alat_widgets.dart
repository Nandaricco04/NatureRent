import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerEmptyProduct extends StatelessWidget {
  const OwnerEmptyProduct({super.key});

  static const _green = Color(0xFF297B2D);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          const Icon(Icons.inventory_2_outlined, color: _green, size: 54),
          const SizedBox(height: 12),
          Text(
            'Belum ada alat',
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tambahkan alat rental pertama untuk toko kamu.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6D6A66),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerNoSearchResult extends StatelessWidget {
  const OwnerNoSearchResult({super.key});

  static const _green = Color(0xFF297B2D);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 90),
      child: Column(
        children: [
          const Icon(Icons.search_off, color: _green, size: 54),
          const SizedBox(height: 12),
          Text(
            'Alat tidak ada',
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coba gunakan kata kunci lain.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF6D6A66),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerToolCard extends StatelessWidget {
  const OwnerToolCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Map<String, dynamic> product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const _green = Color(0xFF297B2D);
  static const _orange = Color(0xFFFB8C00);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    final name = (product['name'] ?? '-').toString();
    final description = (product['description'] ?? '').toString();
    final price = product['price_per_day'] ?? 0;
    final stock = product['stock'] ?? 0;
    final imageUrl = (product['image_url'] ?? '').toString();
    final rating = product['rating'] ?? 0;
    final kapasitas = (product['kapasitas'] ?? '').toString();
    final category = (product['categories']?['name'] ?? '').toString();
    final detail = [
      if (category.isNotEmpty) category,
      if (kapasitas.isNotEmpty) 'kapasitas $kapasitas',
    ].join(' ');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 76,
                      height: 76,
                      color: const Color(0xFFE9F3EA),
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.terrain, color: _green, size: 38)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) {
                                return const Icon(
                                  Icons.terrain,
                                  color: _green,
                                  size: 38,
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _InfoPill(
                        text: '$stock Tersedia',
                        backgroundColor: const Color(0xFFD7F5D8),
                        textColor: _green,
                      ),
                      const SizedBox(width: 8),
                      _InfoPill(
                        text: '0 Disewa',
                        backgroundColor: const Color(0xFFFFD8C8),
                        textColor: _orange,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 150,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          color: _text,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      detail.isEmpty ? description : detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF8CBF90),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                          color: _green,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        children: [
                          TextSpan(text: 'Rp$price'),
                          TextSpan(
                            text: ' /hari',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6D6A66),
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: _orange, size: 14),
              const SizedBox(width: 3),
              Text(
                rating.toString(),
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              _ActionButton(
                text: 'Iklankan',
                backgroundColor: const Color(0xFF9AF0A2),
                textColor: _green,
                onPressed: () {},
              ),
              const SizedBox(width: 10),
              _ActionButton(
                text: 'Edit',
                backgroundColor: const Color(0xFFD8E8FF),
                textColor: const Color(0xFF3977D8),
                onPressed: onEdit,
              ),
              const SizedBox(width: 10),
              _ActionButton(
                text: 'Hapus',
                backgroundColor: const Color(0xFFEFB0B0),
                textColor: const Color(0xFFB52020),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class OwnerDeleteProductSheet extends StatefulWidget {
  const OwnerDeleteProductSheet({
    super.key,
    required this.productName,
    required this.stock,
    required this.price,
    required this.onDelete,
  });

  final String productName;
  final dynamic stock;
  final dynamic price;
  final Future<void> Function() onDelete;

  @override
  State<OwnerDeleteProductSheet> createState() =>
      _OwnerDeleteProductSheetState();
}

class _OwnerDeleteProductSheetState extends State<OwnerDeleteProductSheet> {
  bool _deleting = false;

  static const _green = Color(0xFF297B2D);
  static const _text = Color(0xFF212121);

  Future<void> _delete() async {
    setState(() => _deleting = true);
    try {
      await widget.onDelete();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _deleting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus alat: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(44, 40, 44, 34),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 108,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F3EA),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF9BCB9E)),
            ),
            child: const Icon(
              Icons.delete_outline,
              color: Color(0xFF8DBD91),
              size: 58,
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'Hapus Alat Ini?',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: _text,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Data alat akan dihapus permanen dan tidak bisa dikembalikan',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: _text, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F2ED),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              children: [
                Text(
                  widget.productName,
                  style: GoogleFonts.poppins(
                    color: _text,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Stok : ${widget.stock}  Rp${widget.price}/hari',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6D6A66),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextButton(
                    onPressed: _deleting ? null : () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F2ED),
                      foregroundColor: _green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: Text(
                      'Batal',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 36,
                  child: TextButton(
                    onPressed: _deleting ? null : _delete,
                    style: TextButton.styleFrom(
                      backgroundColor: const Color(0xFFC42D2D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    child: _deleting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Ya, Hapus',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: textColor,
          fontSize: 9,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onPressed,
  });

  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      height: 22,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
