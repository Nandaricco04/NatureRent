import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerLaporanPage extends StatelessWidget {
  const OwnerLaporanPage({super.key});

  static const _green = Color(0xFF297B2D);
  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.insert_chart_outlined, size: 52, color: _green),
            const SizedBox(height: 14),
            Text(
              'Laporan',
              style: GoogleFonts.poppins(
                color: _text,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ringkasan pendapatan dan performa toko.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF6D6A66),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
