import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/owner_document_upload_service.dart';

class AuthUploadField extends StatelessWidget {
  const AuthUploadField({
    super.key,
    required this.label,
    required this.state,
    required this.onPick,
  });

  final String label;
  final OwnerUploadState state;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final isImage =
        state.ext == 'jpg' || state.ext == 'jpeg' || state.ext == 'png';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: state.loading ? null : onPick,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE2E2E2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                if (state.loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  const Icon(Icons.upload_file),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.loading ? 'Mengupload...' : (state.name ?? label),
                    style: GoogleFonts.poppins(fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (state.url != null) ...[
          const SizedBox(height: 8),
          if (isImage)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                state.url!,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.picture_as_pdf, size: 18),
                const SizedBox(width: 6),
                Text(
                  state.name ?? 'Dokumen terupload',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
