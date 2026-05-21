import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UserSupportColors {
  static const green = Color(0xFF297B2D);
  static const background = Color(0xFFF5F2ED);
  static const text = Color(0xFF212121);
  static const muted = Color(0xFF5D5D5D);
  static const border = Color(0xFFD8D3CE);
}

class UserSupportHeader extends StatelessWidget {
  const UserSupportHeader({super.key, required this.onBack});

  final VoidCallback onBack;

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
              child: Icon(
                Icons.arrow_back,
                color: UserSupportColors.text,
                size: 20,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'Bantuan & Dukungan',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: UserSupportColors.text,
          ),
        ),
      ],
    );
  }
}

class UserSupportIntro extends StatelessWidget {
  const UserSupportIntro({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selamat Datang',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: UserSupportColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fitur Bantuan dan Dukungan pada aplikasi Naturent berfungsi untuk '
          'memberikan layanan informasi, panduan penggunaan, serta media '
          'komunikasi antara pengguna dan pengelola aplikasi. Dengan adanya '
          'fitur ini, pengguna dapat memperoleh bantuan dengan lebih mudah dan '
          'cepat sehingga meningkatkan kepuasan pengguna terhadap layanan '
          'aplikasi Naturent.',
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: UserSupportColors.muted,
            height: 1.55,
          ),
        ),
      ],
    );
  }
}

class UserSupportFormCard extends StatelessWidget {
  const UserSupportFormCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(15, 18, 15, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: UserSupportColors.green,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class UserSupportTextField extends StatelessWidget {
  const UserSupportTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.readOnly = false,
    this.keyboardType,
    this.maxLines = 1,
  });

  final String hint;
  final TextEditingController controller;
  final bool readOnly;
  final TextInputType? keyboardType;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: UserSupportColors.text,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            fontSize: 12,
            color: const Color(0xFF8F8F8F),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 13,
          ),
          disabledBorder: _border(),
          border: _border(),
          enabledBorder: _border(),
          focusedBorder: _border(color: UserSupportColors.green),
        ),
      ),
    );
  }

  OutlineInputBorder _border({Color color = UserSupportColors.border}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: BorderSide(color: color),
    );
  }
}

class UserSupportAttachmentField extends StatelessWidget {
  const UserSupportAttachmentField({
    super.key,
    required this.imageName,
    required this.uploading,
    required this.disabled,
    required this.onPick,
    required this.onClear,
  });

  final String? imageName;
  final bool uploading;
  final bool disabled;
  final VoidCallback onPick;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: imageName == null ? 2 : 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: disabled || uploading ? null : onPick,
        child: InputDecorator(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 13,
            ),
            border: _border(),
            enabledBorder: _border(),
          ),
          child: Row(
            children: [
              if (uploading)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                const Icon(
                  Icons.upload_file,
                  size: 18,
                  color: UserSupportColors.muted,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  uploading ? 'Mengupload...' : (imageName ?? 'Lampiran'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: imageName == null
                        ? const Color(0xFF8F8F8F)
                        : UserSupportColors.text,
                  ),
                ),
              ),
              if (imageName != null && !uploading)
                GestureDetector(
                  onTap: disabled ? null : onClear,
                  child: const Icon(
                    Icons.close,
                    size: 18,
                    color: UserSupportColors.muted,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: UserSupportColors.border),
    );
  }
}

class UserSupportAttachmentPreview extends StatelessWidget {
  const UserSupportAttachmentPreview({
    super.key,
    required this.bytes,
    required this.url,
    required this.uploading,
    required this.disabled,
    required this.onClear,
  });

  final Uint8List bytes;
  final String? url;
  final bool uploading;
  final bool disabled;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            width: double.infinity,
            height: 170,
            color: UserSupportColors.background,
            child: url == null
                ? Image.memory(bytes, fit: BoxFit.cover)
                : Image.network(url!, fit: BoxFit.cover),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Material(
            color: Colors.black.withOpacity(0.55),
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: disabled || uploading ? null : onClear,
              child: const SizedBox(
                width: 30,
                height: 30,
                child: Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ),
        if (uploading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.45),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Mengupload lampiran...',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class UserSupportActionButtons extends StatelessWidget {
  const UserSupportActionButtons({
    super.key,
    required this.saving,
    required this.onSubmit,
    required this.onCancel,
  });

  final bool saving;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 45,
          child: ElevatedButton(
            onPressed: saving ? null : onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: UserSupportColors.green,
              disabledBackgroundColor: UserSupportColors.green.withOpacity(0.6),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    'Kirim Complain',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 45,
          child: OutlinedButton(
            onPressed: saving ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: UserSupportColors.text,
              side: const BorderSide(color: UserSupportColors.text),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              'Batalkan',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
