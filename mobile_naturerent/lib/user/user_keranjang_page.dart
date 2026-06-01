import 'package:flutter/material.dart';

import 'services/user_keranjang_service.dart';
import 'widgets/user_keranjang_checkout_widgets.dart';
import 'widgets/user_keranjang_selection_widgets.dart';

class UserKeranjangPage extends StatefulWidget {
  const UserKeranjangPage({
    super.key,
    this.initialSelectedCartId,
    this.openCheckoutOnLoad = false,
    this.popCheckoutOnBack = false,
    this.checkoutBackSignal = 0,
    this.onCheckoutModeChanged,
    this.onCheckoutComplete,
  });

  final dynamic initialSelectedCartId;
  final bool openCheckoutOnLoad;
  final bool popCheckoutOnBack;
  final int checkoutBackSignal;
  final ValueChanged<bool>? onCheckoutModeChanged;
  final VoidCallback? onCheckoutComplete;

  @override
  State<UserKeranjangPage> createState() => _UserKeranjangPageState();
}

class _UserKeranjangPageState extends State<UserKeranjangPage> {
  final _service = UserKeranjangService();

  static const _background = Color(0xFFF7F6F2);
  static const _taxRate = 0.10;

  final Set<String> selectedCartIds = {};
  List<Map<String, dynamic>> carts = [];
  bool isLoading = true;
  bool isCheckingOut = false;
  bool isUploadingProof = false;
  bool showCheckout = false;
  bool _initialCheckoutApplied = false;
  String paymentMethod = '';
  String? buktiPembayaranUrl;

  List<Map<String, dynamic>> get selectedCarts {
    return carts
        .where((item) => selectedCartIds.contains(_cartKey(item)))
        .toList();
  }

  int get subtotalSewa {
    return selectedCarts.fold<int>(0, (total, item) {
      return total + _readInt(item['subtotal']);
    });
  }

  int get pajak => (subtotalSewa * _taxRate).round();

  int get totalHarga => subtotalSewa + pajak;

  int get totalSelectedItems => selectedCarts.length;

  @override
  void initState() {
    super.initState();
    _getKeranjang();
  }

  @override
  void didUpdateWidget(covariant UserKeranjangPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checkoutBackSignal != oldWidget.checkoutBackSignal &&
        showCheckout) {
      setState(() => _setCheckoutMode(false));
    }
  }

  Future<void> _getKeranjang() async {
    try {
      final rows = await _service.fetchCart();

      if (!mounted) return;
      setState(() {
        carts = rows;
        if (!_initialCheckoutApplied && widget.initialSelectedCartId != null) {
          final initialId = widget.initialSelectedCartId.toString();
          if (rows.any((item) => _cartKey(item) == initialId)) {
            selectedCartIds.add(initialId);
            _setCheckoutMode(widget.openCheckoutOnLoad);
          }
          _initialCheckoutApplied = true;
        }
        selectedCartIds.removeWhere(
          (id) => !rows.any((item) => _cartKey(item) == id),
        );
        if (selectedCartIds.isEmpty) _setCheckoutMode(false);
        isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR KERANJANG: $e');

      if (!mounted) return;
      setState(() => isLoading = false);
      _showMessage('Gagal memuat keranjang');
    }
  }

  Future<void> _updateJumlah(Map<String, dynamic> item, int newQuantity) async {
    try {
      await _service.updateQuantity(item, newQuantity);
      await _getKeranjang();
    } catch (e) {
      debugPrint('ERROR UPDATE KERANJANG: $e');
      _showMessage('Gagal memperbarui keranjang');
    }
  }

  Future<void> _checkout() async {
    if (selectedCarts.isEmpty || isCheckingOut) return;
    if (paymentMethod.isEmpty) {
      _showMessage('Pilih metode pembayaran dulu');
      return;
    }
    if (paymentMethod == 'qris' && buktiPembayaranUrl == null) {
      _showMessage('Upload bukti pembayaran QRIS dulu');
      return;
    }

    setState(() => isCheckingOut = true);

    try {
      final kode = await _service.checkout(
        selectedCarts: selectedCarts,
        paymentMethod: paymentMethod,
        subtotalSewa: subtotalSewa,
        pajak: pajak,
        totalHarga: totalHarga,
        buktiPembayaran: paymentMethod == 'qris' ? buktiPembayaranUrl : null,
      );

      if (!mounted) return;
      setState(() {
        selectedCartIds.clear();
        paymentMethod = '';
        buktiPembayaranUrl = null;
        _setCheckoutMode(false);
        isCheckingOut = false;
      });
      await _getKeranjang();

      _showMessage('Checkout berhasil: $kode');
      widget.onCheckoutComplete?.call();
    } on UserKeranjangException catch (e) {
      if (!mounted) return;
      setState(() => isCheckingOut = false);
      _showMessage(e.message);
    } catch (e) {
      debugPrint('ERROR CHECKOUT: $e');

      if (!mounted) return;
      setState(() => isCheckingOut = false);
      _showMessage('Checkout gagal: $e');
    }
  }

  Future<void> _pickPaymentProof() async {
    if (isUploadingProof) return;

    setState(() => isUploadingProof = true);

    try {
      final proofUrl = await _service.pickAndUploadPaymentProof();
      if (!mounted) return;

      setState(() {
        if (proofUrl != null) buktiPembayaranUrl = proofUrl;
        isUploadingProof = false;
      });

      if (proofUrl != null) {
        _showMessage('Bukti pembayaran berhasil diupload');
      }
    } on UserKeranjangException catch (e) {
      if (!mounted) return;
      setState(() => isUploadingProof = false);
      _showMessage(e.message);
    } catch (e) {
      debugPrint('ERROR UPLOAD BUKTI CHECKOUT: $e');
      if (!mounted) return;
      setState(() => isUploadingProof = false);
      _showMessage('Gagal upload bukti pembayaran');
    }
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  String _cartKey(Map<String, dynamic> item) {
    return item['id_keranjang'].toString();
  }

  String _storeKey(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    return (product?['owner_id'] ?? _storeName(item)).toString();
  }

  String _storeName(Map<String, dynamic> item) {
    final product = item['products'] as Map<String, dynamic>?;
    return product?['owner']?['nama_toko']?.toString() ?? 'Toko Outdoor';
  }

  Map<String, List<Map<String, dynamic>>> _groupByStore() {
    final grouped = <String, List<Map<String, dynamic>>>{};

    for (final item in carts) {
      final key = _storeKey(item);
      grouped.putIfAbsent(key, () => []);
      grouped[key]!.add(item);
    }

    return grouped;
  }

  void _toggleItem(Map<String, dynamic> item) {
    final key = _cartKey(item);
    setState(() {
      if (selectedCartIds.contains(key)) {
        selectedCartIds.remove(key);
      } else {
        selectedCartIds.add(key);
      }
      if (selectedCartIds.isEmpty) showCheckout = false;
      if (selectedCartIds.isEmpty) _setCheckoutMode(false);
      if (selectedCartIds.isEmpty) buktiPembayaranUrl = null;
      if (selectedCartIds.isEmpty) paymentMethod = '';
    });
  }

  void _toggleStore(List<Map<String, dynamic>> items) {
    final allSelected = items.every(
      (item) => selectedCartIds.contains(_cartKey(item)),
    );

    setState(() {
      for (final item in items) {
        final key = _cartKey(item);
        if (allSelected) {
          selectedCartIds.remove(key);
        } else {
          selectedCartIds.add(key);
        }
      }
      if (selectedCartIds.isEmpty) _setCheckoutMode(false);
    });
  }

  void _handleCheckoutQuantityChanged(
    Map<String, dynamic> item,
    int newQuantity,
  ) {
    _handleQuantityChanged(item, newQuantity);
  }

  void _handleSelectionQuantityChanged(
    Map<String, dynamic> item,
    int newQuantity,
  ) {
    _handleQuantityChanged(item, newQuantity);
  }

  void _handleQuantityChanged(Map<String, dynamic> item, int newQuantity) {
    final product = item['products'] as Map<String, dynamic>?;
    final stock = _readInt(product?['stock']);
    final currentQuantity = _readInt(item['jumlah']);

    if (newQuantity > currentQuantity &&
        stock > 0 &&
        currentQuantity >= stock) {
      _showMessage('Stok hanya tersedia $stock');
      return;
    }

    _updateJumlah(item, newQuantity);
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _setCheckoutMode(bool value) {
    showCheckout = value;
    widget.onCheckoutModeChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : carts.isEmpty
            ? UserKeranjangEmpty(onBack: () => Navigator.maybePop(context))
            : showCheckout
            ? UserKeranjangCheckoutView(
                items: selectedCarts,
                totalItems: totalSelectedItems,
                subtotalSewa: subtotalSewa,
                pajak: pajak,
                totalHarga: totalHarga,
                paymentMethod: paymentMethod,
                buktiPembayaranUrl: buktiPembayaranUrl,
                isCheckingOut: isCheckingOut,
                isUploadingProof: isUploadingProof,
                onBack: _handleCheckoutBack,
                onPaymentChanged: _handlePaymentChanged,
                onPickPaymentProof: _pickPaymentProof,
                onQuantityChanged: _handleCheckoutQuantityChanged,
                onCheckout: _checkout,
              )
            : _buildCartSelectionView(),
      ),
    );
  }

  Widget _buildCartSelectionView() {
    final grouped = _groupByStore();

    return UserKeranjangSelectionView(
      groupedItems: grouped.values,
      selectedCartIds: selectedCartIds,
      totalSelectedItems: totalSelectedItems,
      onBack: () => Navigator.maybePop(context),
      onToggleStore: _toggleStore,
      onToggleItem: _toggleItem,
      onQuantityChanged: _handleSelectionQuantityChanged,
      onBooking: () => setState(() => _setCheckoutMode(true)),
    );
  }

  void _handleCheckoutBack() {
    if (widget.popCheckoutOnBack) {
      Navigator.maybePop(context);
      return;
    }

    setState(() => _setCheckoutMode(false));
  }

  Future<void> _handlePaymentChanged(String value) async {
    if (value == 'qris' && paymentMethod != 'qris') {
      final confirmed = await _showQrisPolicyDialog();
      if (!confirmed) return;
    }

    if (!mounted) return;
    setState(() {
      paymentMethod = value;
      if (value != 'qris') buktiPembayaranUrl = null;
    });
  }

  Future<bool> _showQrisPolicyDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Ketentuan QRIS',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'Pesanan yang sudah dibayar menggunakan QRIS tidak dapat dibatalkan oleh penyewa. Dana yang sudah dibayarkan tidak dapat dikembalikan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF297B2D),
                side: const BorderSide(color: Color(0xFF297B2D)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
              ),
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF297B2D),
                foregroundColor: Colors.white,
              ),
              child: const Text('Saya Mengerti'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}
