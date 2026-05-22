import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthLocationDropdown extends StatelessWidget {
  const AuthLocationDropdown({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Kota', style: GoogleFonts.poppins(fontSize: 13)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFE2E2E2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: value,
              hint: Text(
                'Pilih kota',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<int>(
                  value: item['id_lokasi'] as int,
                  child: Text(item['nama_kota'].toString()),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

class AuthBankDropdown extends StatelessWidget {
  const AuthBankDropdown({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<String> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final currentValue = options.contains(value) ? value : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text('Pilih Bank', style: GoogleFonts.poppins(fontSize: 13)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: currentValue,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Color(0xFF7A7A7A),
          ),
          items: options.map((bank) {
            return DropdownMenuItem<String>(
              value: bank,
              child: Text(bank, style: GoogleFonts.poppins(fontSize: 13)),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Pilih Bank',
            hintStyle: GoogleFonts.poppins(fontSize: 13),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E2E2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF297B2D)),
            ),
          ),
        ),
      ],
    );
  }
}
