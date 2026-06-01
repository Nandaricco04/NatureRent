import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ownerEditPesananGreen = Color(0xFF297B2D);
const ownerEditPesananYellow = Color(0xFFFFCB31);
const ownerEditPesananOrange = Color(0xFFFF8A00);
const ownerEditPesananBackground = Color(0xFFF3F1ED);

class OwnerEditPesananHeader extends StatelessWidget {
  const OwnerEditPesananHeader({
    super.key,
    required this.title,
    required this.onBack,
  });

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 20),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.poppins(
            color: const Color(0xFF212121),
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class OwnerEditPesananInfoCard extends StatelessWidget {
  const OwnerEditPesananInfoCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class OwnerEditPesananSectionTitle extends StatelessWidget {
  const OwnerEditPesananSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: ownerEditPesananGreen,
        fontSize: 13,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class OwnerEditPesananIdCard extends StatelessWidget {
  const OwnerEditPesananIdCard({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return OwnerEditPesananInfoCard(
      children: [
        const OwnerEditPesananSectionTitle('ID Pesanan'),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFC8E6C9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              code,
              style: GoogleFonts.poppins(
                color: ownerEditPesananGreen,
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OwnerEditPesananField extends StatelessWidget {
  const OwnerEditPesananField({
    super.key,
    required this.label,
    required this.value,
    this.trailing,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OwnerEditPesananSectionTitle(label),
        const SizedBox(height: 7),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: OwnerEditPesananReadOnlyBox(value: value, trailing: trailing),
        ),
      ],
    );
  }
}

class OwnerEditPesananReadOnlyBox extends StatelessWidget {
  const OwnerEditPesananReadOnlyBox({
    super.key,
    required this.value,
    this.trailing,
  });

  final String value;
  final IconData? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 42),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFD6D2CC)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: const Color(0xFF212121),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, color: ownerEditPesananGreen, size: 18),
          ],
        ],
      ),
    );
  }
}

class OwnerEditPesananDateBox extends StatelessWidget {
  const OwnerEditPesananDateBox({
    super.key,
    required this.label,
    required this.text,
  });

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OwnerEditPesananSectionTitle(label),
        const SizedBox(height: 7),
        Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFD6D2CC)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF212121),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const Icon(Icons.calendar_month_outlined, size: 18),
            ],
          ),
        ),
      ],
    );
  }
}

class OwnerEditPesananStatusCard extends StatelessWidget {
  const OwnerEditPesananStatusCard({
    super.key,
    required this.status,
    required this.locked,
    required this.onChanged,
  });

  final String status;
  final bool locked;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return OwnerEditPesananInfoCard(
      children: [
        const OwnerEditPesananSectionTitle('Status Pesanan'),
        if (locked) ...[
          const SizedBox(height: 6),
          Text(
            'Status sudah selesai dan tidak bisa diubah lagi.',
            style: GoogleFonts.poppins(
              color: const Color(0xFF6D6A66),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        const SizedBox(height: 10),
        OwnerEditPesananStatusOption(
          value: 'dipesan',
          title: 'Dipesan',
          subtitle: 'Pesanan sedang aktif / belum diambil',
          color: ownerEditPesananYellow,
          selectedValue: status,
          locked: locked,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        OwnerEditPesananStatusOption(
          value: 'diambil',
          title: 'Diambil',
          subtitle: 'Produk sudah diambil oleh penyewa',
          color: ownerEditPesananOrange,
          selectedValue: status,
          locked: locked,
          onChanged: onChanged,
        ),
        const SizedBox(height: 10),
        OwnerEditPesananStatusOption(
          value: 'selesai',
          title: 'Selesai',
          subtitle: 'Produk sudah dikembalikan',
          color: ownerEditPesananGreen,
          selectedValue: status,
          locked: locked,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class OwnerEditPesananStatusOption extends StatelessWidget {
  const OwnerEditPesananStatusOption({
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.selectedValue,
    required this.locked,
    required this.onChanged,
  });

  final String value;
  final String title;
  final String subtitle;
  final Color color;
  final String selectedValue;
  final bool locked;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = selectedValue == value;
    final disabled = locked && value != 'selesai';

    return InkWell(
      onTap: disabled || locked ? null : () => onChanged(value),
      borderRadius: BorderRadius.circular(9),
      child: Container(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFC8E6C9) : Colors.white,
          border: Border.all(color: const Color(0xFFD6D2CC)),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected
                  ? ownerEditPesananGreen
                  : disabled
                  ? const Color(0xFFE3E0DA)
                  : const Color(0xFFD6D2CC),
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: disabled
                          ? const Color(0xFF9A9690)
                          : const Color(0xFF212121),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF55524E),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 72,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
