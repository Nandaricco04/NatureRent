import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OwnerAlatFormHeader extends StatelessWidget {
  const OwnerAlatFormHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onBack,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;

  static const _text = Color(0xFF212121);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.arrow_back, color: _text),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: _text,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF6D6A66),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class OwnerAlatImagePickerBox extends StatelessWidget {
  const OwnerAlatImagePickerBox({
    super.key,
    required this.imageUrl,
    required this.editMode,
    required this.uploading,
    required this.onTap,
  });

  final String? imageUrl;
  final bool editMode;
  final bool uploading;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 102,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (imageUrl == null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Upload Foto Alat',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFA4B6A7),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'JPG, PNG - Maks. 5MB',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFF9C9C9C),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              )
            else
              Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return const Icon(Icons.image_not_supported_outlined);
                },
              ),
            if (editMode && imageUrl != null)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8CAF91),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Ganti Foto',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            if (uploading)
              Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
