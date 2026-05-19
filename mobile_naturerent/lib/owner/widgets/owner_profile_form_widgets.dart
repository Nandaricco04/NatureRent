import 'package:flutter/material.dart';

class OwnerProfileColors {
  const OwnerProfileColors._();

  static const green = Color(0xFF297B2D);
  static const background = Color(0xFFF5F2ED);
  static const border = Color(0xFFD8D3CE);
  static const label = Color(0xFF212121);
}

class OwnerProfileHeader extends StatelessWidget {
  const OwnerProfileHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 36,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(color: OwnerProfileColors.border),
                ),
                child: const Icon(
                  Icons.arrow_back,
                  size: 18,
                  color: OwnerProfileColors.label,
                ),
              ),
            ),
          ),
          const Text(
            'Edit Profil Toko',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: OwnerProfileColors.label,
            ),
          ),
        ],
      ),
    );
  }
}

class OwnerProfileAvatar extends StatelessWidget {
  const OwnerProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.displayName,
    required this.email,
    required this.uploading,
  });

  final String? photoUrl;
  final String displayName;
  final String email;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 44,
              backgroundColor: const Color(0xFFE9F3EA),
              backgroundImage: photoUrl != null
                  ? NetworkImage(photoUrl!)
                  : null,
              child: photoUrl == null
                  ? const Icon(
                      Icons.storefront,
                      size: 40,
                      color: OwnerProfileColors.green,
                    )
                  : null,
            ),
            if (uploading)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          displayName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: OwnerProfileColors.label,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          email,
          style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
        ),
      ],
    );
  }
}

class OwnerChangePhotoButton extends StatelessWidget {
  const OwnerChangePhotoButton({
    super.key,
    required this.uploading,
    required this.onPressed,
  });

  final bool uploading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 150,
        height: 36,
        child: OutlinedButton(
          onPressed: uploading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: OwnerProfileColors.label,
            side: const BorderSide(color: OwnerProfileColors.label),
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: uploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: OwnerProfileColors.label,
                  ),
                )
              : const Text(
                  'Ganti Foto Profil',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
        ),
      ),
    );
  }
}

class OwnerProfileCard extends StatelessWidget {
  const OwnerProfileCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: OwnerProfileColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: OwnerProfileColors.green,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class OwnerProfileTextField extends StatelessWidget {
  const OwnerProfileTextField({
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
        decoration: ownerProfileInputDecoration(
          hint,
          fillColor: readOnly ? const Color(0xFFF8F8F8) : Colors.white,
        ),
      ),
    );
  }
}

class OwnerPasswordField extends StatelessWidget {
  const OwnerPasswordField({
    super.key,
    required this.controller,
    required this.obscureText,
    required this.onToggle,
  });

  final TextEditingController controller;
  final bool obscureText;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration:
            ownerProfileInputDecoration(
              'Password baru (kosongkan jika tidak diubah)',
              hintFontSize: 12,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscureText
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: const Color(0xFF7A7A7A),
                ),
              ),
            ),
      ),
    );
  }
}

class OwnerLocationDropdown extends StatelessWidget {
  const OwnerLocationDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final int? value;
  final List<Map<String, dynamic>> items;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<int>(
        initialValue: value,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF7A7A7A),
        ),
        items: items.map((item) {
          return DropdownMenuItem<int>(
            value: item['id_lokasi'] as int,
            child: Text(
              item['nama_kota'].toString(),
              style: const TextStyle(fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: ownerProfileInputDecoration('Kota / Kabupaten'),
      ),
    );
  }
}

class OwnerBankDropdown extends StatelessWidget {
  const OwnerBankDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String? value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final currentValue = options.contains(value) ? value : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        initialValue: currentValue,
        isExpanded: true,
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Color(0xFF7A7A7A),
        ),
        items: options.map((bank) {
          return DropdownMenuItem<String>(
            value: bank,
            child: Text(bank, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: onChanged,
        decoration: ownerProfileInputDecoration('Pilih Bank'),
      ),
    );
  }
}

class OwnerProfileSaveButton extends StatelessWidget {
  const OwnerProfileSaveButton({
    super.key,
    required this.saving,
    required this.onPressed,
  });

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: saving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: OwnerProfileColors.green,
          disabledBackgroundColor: OwnerProfileColors.green.withValues(
            alpha: 0.6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
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
            : const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class OwnerProfileCancelButton extends StatelessWidget {
  const OwnerProfileCancelButton({
    super.key,
    required this.saving,
    required this.onPressed,
  });

  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: OutlinedButton(
        onPressed: saving ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: OwnerProfileColors.label,
          side: const BorderSide(color: OwnerProfileColors.label),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Batalkan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

InputDecoration ownerProfileInputDecoration(
  String hint, {
  double hintFontSize = 13,
  Color fillColor = Colors.white,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: hintFontSize,
      color: const Color(0xFFAAAAAA),
    ),
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: OwnerProfileColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: OwnerProfileColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: OwnerProfileColors.green, width: 1.5),
    ),
  );
}
