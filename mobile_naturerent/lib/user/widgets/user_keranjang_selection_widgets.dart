import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../widgets/app_alerts.dart';

class UserKeranjangSelectionView extends StatelessWidget {
  const UserKeranjangSelectionView({
    super.key,
    required this.groupedItems,
    required this.selectedCartIds,
    required this.totalSelectedItems,
    required this.onBack,
    required this.onToggleStore,
    required this.onToggleItem,
    required this.onQuantityChanged,
    required this.onBooking,
  });

  final Iterable<List<Map<String, dynamic>>> groupedItems;
  final Set<String> selectedCartIds;
  final int totalSelectedItems;
  final VoidCallback onBack;
  final ValueChanged<List<Map<String, dynamic>>> onToggleStore;
  final ValueChanged<Map<String, dynamic>> onToggleItem;
  final void Function(Map<String, dynamic> item, int quantity)
  onQuantityChanged;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserKeranjangHeader(onBack: onBack),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
            children: groupedItems.map(_buildStoreGroup).toList(),
          ),
        ),
        if (selectedCartIds.isNotEmpty)
          _SelectionBar(totalItems: totalSelectedItems, onBooking: onBooking),
      ],
    );
  }

  Widget _buildStoreGroup(List<Map<String, dynamic>> items) {
    final allSelected = items.every((item) => _isSelected(item));

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => onToggleStore(items),
            child: Row(
              children: [
                _SelectionCircle(selected: allSelected),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _storeName(items.first),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE7E1DB)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  _buildSelectableItem(items[i]),
                  if (i != items.length - 1)
                    const Divider(
                      height: 1,
                      indent: 52,
                      endIndent: 12,
                      color: Color(0xFFE7E1DB),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          InkWell(
            onTap: () => onToggleItem(item),
            child: _SelectionCircle(selected: _isSelected(item)),
          ),
          const SizedBox(width: 10),
          Expanded(child: _ProductInfo(item: item)),
          _QuantityControls(item: item, onQuantityChanged: onQuantityChanged),
        ],
      ),
    );
  }

  bool _isSelected(Map<String, dynamic> item) {
    return selectedCartIds.contains(_cartKey(item));
  }

  String _cartKey(Map<String, dynamic> item) {
    return item['id_keranjang'].toString();
  }

  String _storeName(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    return product?['owner']?['nama_toko']?.toString() ?? 'Toko Outdoor';
  }
}

class UserKeranjangHeader extends StatelessWidget {
  const UserKeranjangHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}

class UserKeranjangEmpty extends StatelessWidget {
  const UserKeranjangEmpty({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UserKeranjangHeader(onBack: onBack),
        const Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 52,
                    color: Color(0xFF297B2D),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Keranjang Kosong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF212121),
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Belum ada alat di keranjang.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF6D6A66)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductInfo extends StatelessWidget {
  const _ProductInfo({required this.item});

  static const _green = Color(0xFF297B2D);

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final product = item['products'] as Map<String, dynamic>?;

    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            product?['image_url'] ?? '',
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 72,
                height: 72,
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
}

class _QuantityControls extends StatelessWidget {
  const _QuantityControls({
    required this.item,
    required this.onQuantityChanged,
  });

  static const _green = Color(0xFF297B2D);

  final Map<String, dynamic> item;
  final void Function(Map<String, dynamic> item, int quantity)
  onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final quantity = _readInt(item['jumlah']);
    final stock = _readInt(item['products']?['stock']);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _quantityButton(
          icon: Icons.remove,
          background: const Color(0xffF3F1ED),
          foreground: Colors.black87,
          onTap: () {
            final newQty = quantity - 1;

            if (newQty <= 0) {
              // 🔥 hapus item
              onQuantityChanged(item, 0);
            } else {
              onQuantityChanged(item, newQty);
            }
          },
        ),

        SizedBox(
          width: 40,
          child: TextField(
            controller: TextEditingController(text: quantity.toString()),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),
            onSubmitted: (value) {
              final input = int.tryParse(value);

              int newQty;

              if (input == null || input <= 0) {
                newQty = 0; // 🔥 akan trigger delete
              } else if (input > stock) {
                newQty = stock;

                AppAlerts.showSnackBar(
                  context,
                  message: 'Stok hanya tersedia $stock',
                  subtitle: 'Kurangi jumlah alat agar sesuai stok toko.',
                  type: AppAlertType.warning,
                );
              } else {
                newQty = input;
              }

              onQuantityChanged(item, newQty);
            },
          ),
        ),

        _quantityButton(
          icon: Icons.add,
          background: _green,
          foreground: Colors.white,
          onTap: () {
            if (quantity < stock) {
              onQuantityChanged(item, quantity + 1);
            } else {
              AppAlerts.showSnackBar(
                context,
                message: 'Stok hanya tersedia $stock',
                subtitle: 'Kurangi jumlah alat agar sesuai stok toko.',
                type: AppAlertType.warning,
              );
            }
          },
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
}

class _SelectionCircle extends StatelessWidget {
  const _SelectionCircle({required this.selected});

  static const _green = Color(0xFF297B2D);

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? _green : Colors.white,
        border: Border.all(
          color: selected ? _green : const Color(0xFFE7E1DB),
          width: 1.2,
        ),
      ),
      child: selected
          ? const Icon(Icons.check, color: Colors.white, size: 14)
          : null,
    );
  }
}

class _SelectionBar extends StatelessWidget {
  const _SelectionBar({required this.totalItems, required this.onBooking});

  static const _green = Color(0xFF297B2D);

  final int totalItems;
  final VoidCallback onBooking;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E0D8))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: onBooking,
          style: ElevatedButton.styleFrom(
            backgroundColor: _green,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Booking $totalItems Item',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
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
