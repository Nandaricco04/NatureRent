import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserKeranjangCheckoutView extends StatelessWidget {
  const UserKeranjangCheckoutView({
    super.key,
    required this.items,
    required this.totalItems,
    required this.subtotalSewa,
    required this.pajak,
    required this.totalHarga,
    required this.paymentMethod,
    required this.buktiPembayaranUrl,
    required this.isCheckingOut,
    required this.isUploadingProof,
    required this.onBack,
    required this.onPaymentChanged,
    required this.onPickPaymentProof,
    required this.onQuantityChanged,
    required this.onCheckout,
  });

  static const _green = Color(0xFF297B2D);

  final List<Map<String, dynamic>> items;
  final int totalItems;
  final int subtotalSewa;
  final int pajak;
  final int totalHarga;
  final String paymentMethod;
  final String? buktiPembayaranUrl;
  final bool isCheckingOut;
  final bool isUploadingProof;
  final VoidCallback onBack;
  final ValueChanged<String> onPaymentChanged;
  final VoidCallback onPickPaymentProof;
  final void Function(Map<String, dynamic> item, int quantity)
  onQuantityChanged;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            children: [
              ...items.map(_buildCheckoutItem),
              const SizedBox(height: 8),
              _buildPaymentMethod(),
              const SizedBox(height: 14),
              _buildSummaryCard(),
              if (paymentMethod == 'qris') ...[
                const SizedBox(height: 24),
                _buildQrisBox(),
                const SizedBox(height: 24),
                _buildProofPicker(),
              ],
            ],
          ),
        ),
        _buildCheckoutBar(),
      ],
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Keranjang',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: _green,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalItems Item',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckoutItem(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildProductInfo(item)),
          _buildQuantityControls(item),
        ],
      ),
    );
  }

  Widget _buildProductInfo(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product?['image_url'] ?? '',
            width: 92,
            height: 92,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 92,
                height: 92,
                color: Colors.grey.shade300,
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product?['name'] ?? 'Alat outdoor',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                '${item['total_hari']} Hari Sewa',
                style: const TextStyle(color: Colors.grey, fontSize: 10),
              ),
              const SizedBox(height: 5),
              Text(
                _formatRp(item['subtotal'] ?? 0),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: _green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityControls(Map<String, dynamic> item) {
    final quantity = _readInt(item['jumlah']);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _quantityButton(
          icon: Icons.remove,
          background: const Color(0xffF3F1ED),
          foreground: Colors.black87,
          onTap: () => onQuantityChanged(item, quantity - 1),
        ),
        SizedBox(
          width: 34,
          child: Text(
            quantity.toString(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ),
        _quantityButton(
          icon: Icons.add,
          background: _green,
          foreground: Colors.white,
          onTap: () => onQuantityChanged(item, quantity + 1),
        ),
      ],
    );
  }

  Widget _quantityButton({
    required IconData icon,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 32,
      height: 32,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Icon(icon, color: foreground, size: 17),
        ),
      ),
    );
  }

  Widget _buildPaymentMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _paymentOption(
                value: 'qris',
                icon: Icons.qr_code_2,
                label: 'QRIS',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _paymentOption(
                value: 'cod',
                icon: Icons.payments_outlined,
                label: 'COD',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _paymentOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final selected = paymentMethod == value;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => onPaymentChanged(value),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? _green : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? _green : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : Colors.black87,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ringkasan Biaya',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _summaryRow('Biaya Sewa', subtotalSewa),
          const SizedBox(height: 10),
          _summaryRow('Pajak Platform (10%)', pajak),
          const Divider(height: 26, color: Colors.black54),
          _summaryRow('Total Bayar', totalHarga, isTotal: true),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, int value, {bool isTotal = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
        Text(
          _formatRp(value),
          style: TextStyle(
            color: isTotal ? _green : Colors.black87,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildCheckoutBar() {
    final canCheckout =
        !isCheckingOut &&
        !isUploadingProof &&
        paymentMethod.isNotEmpty &&
        (paymentMethod != 'qris' || buktiPembayaranUrl != null);

    return Container(
      padding: const EdgeInsets.fromLTRB(30, 16, 30, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E0D8))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Text('Total Bayar'),
              const Spacer(),
              Text(
                _formatRp(totalHarga),
                style: const TextStyle(
                  color: _green,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canCheckout ? onCheckout : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                disabledBackgroundColor: _green.withValues(alpha: 0.45),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isCheckingOut
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Booking Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrisBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _green, width: 2),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              color: Color(0xFFEAF7EC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: const Text(
              'Scan QR Code',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _green,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: 158,
            height: 158,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE7E1D8), width: 2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Image.asset('assets/images/Qris.jpeg', fit: BoxFit.contain),
          ),
          const SizedBox(height: 10),
          const Text(
            'Total yang dibayar',
            style: TextStyle(color: Color(0xFF9A9792), fontSize: 12),
          ),
          Text(
            _formatRp(totalHarga),
            style: const TextStyle(
              color: _green,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 258,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF2EFE8),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Column(
              children: [
                _PaymentStep(
                  number: '1',
                  text: 'Buka aplikasi e-wallet atau\nm-banking kamu',
                ),
                SizedBox(height: 12),
                _PaymentStep(
                  number: '2',
                  text: 'Pilih menu Scan / QRIS lalu scan kode di atas',
                ),
                SizedBox(height: 12),
                _PaymentStep(number: '3', text: 'Konfirmasi pembayaran'),
                SizedBox(height: 12),
                _PaymentStep(number: '4', text: 'Upload bukti tf dibawah'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProofPicker() {
    final uploaded = buktiPembayaranUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Bukti Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: isUploadingProof ? null : onPickPaymentProof,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: double.infinity,
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _green),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (isUploadingProof)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: _green,
                      strokeWidth: 2,
                    ),
                  )
                else
                  Icon(
                    uploaded ? Icons.check_circle : Icons.upload_file,
                    color: uploaded ? _green : Colors.black87,
                  ),
                const SizedBox(width: 10),
                Text(
                  isUploadingProof
                      ? 'Mengupload...'
                      : uploaded
                      ? 'Bukti sudah diupload'
                      : 'Upload File',
                  style: TextStyle(
                    color: uploaded ? _green : Colors.black87,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (uploaded) ...[
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: double.infinity,
              height: 132,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFD9D5CF)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Image.network(
                buktiPembayaranUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Preview bukti tidak bisa dimuat',
                      style: TextStyle(
                        color: Color(0xFF8A8793),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _formatRp(num value) {
    return NumberFormat.currency(
      locale: 'id',
      symbol: 'Rp',
      decimalDigits: 0,
    ).format(value);
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }
}

class _PaymentStep extends StatelessWidget {
  const _PaymentStep({required this.number, required this.text});

  final String number;
  final String text;

  static const _green = Color(0xFF297B2D);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 21,
            height: 21,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _green,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                height: 1.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
