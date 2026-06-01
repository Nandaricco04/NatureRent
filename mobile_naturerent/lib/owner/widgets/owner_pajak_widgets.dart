import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'owner_edit_pesanan_widgets.dart';

class OwnerPajakQrCard extends StatelessWidget {
  const OwnerPajakQrCard({super.key, required this.amountText});

  final String amountText;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FBF7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ownerEditPesananGreen, width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 17),
            decoration: const BoxDecoration(
              color: Color(0xFFE8F6E9),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: ownerEditPesananGreen,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 22, 30, 30),
            child: Column(
              children: [
                Container(
                  width: 160,
                  height: 160,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE6E1D9)),
                  ),
                  child: Image.asset(
                    'assets/images/Qris.jpeg',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Total yang di bayar',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF9A9690),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amountText,
                  style: GoogleFonts.poppins(
                    color: ownerEditPesananGreen,
                    fontSize: 20,
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
}

class OwnerPajakProofUpload extends StatelessWidget {
  const OwnerPajakProofUpload({
    super.key,
    required this.proofUrl,
    required this.uploading,
    required this.onPickProof,
    required this.onPreview,
    required this.fileNameFromUrl,
  });

  final String? proofUrl;
  final bool uploading;
  final VoidCallback onPickProof;
  final VoidCallback onPreview;
  final String Function(String url) fileNameFromUrl;

  @override
  Widget build(BuildContext context) {
    final hasProof = proofUrl != null && proofUrl!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bukti Pembayaran',
            style: GoogleFonts.poppins(
              color: const Color(0xFF212121),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: uploading ? null : onPickProof,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 50,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ownerEditPesananGreen),
              ),
              child: Row(
                children: [
                  Flexible(
                    child: Container(
                      height: 28,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9E9E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (uploading)
                            const SizedBox(
                              width: 15,
                              height: 15,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            const Icon(Icons.upload_file, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              hasProof
                                  ? fileNameFromUrl(proofUrl!)
                                  : 'Upload File',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF2A2A2A),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (hasProof) ...[
            const SizedBox(height: 12),
            InkWell(
              onTap: onPreview,
              borderRadius: BorderRadius.circular(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 170,
                  width: double.infinity,
                  color: Colors.white,
                  child: Image.network(
                    proofUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          color: ownerEditPesananGreen,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Text(
                          'Preview tidak bisa dimuat',
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6D6A66),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
