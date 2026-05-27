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
    required this.isCheckingOut,
    required this.onBack,
    required this.onPaymentChanged,
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
  final bool isCheckingOut;
  final VoidCallback onBack;
  final ValueChanged<String> onPaymentChanged;
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
              onPressed: null,
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
