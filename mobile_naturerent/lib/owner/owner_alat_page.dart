import 'package:flutter/material.dart';

import 'owner_edit_alat_page.dart';
import 'owner_tambah_alat_page.dart';
import 'services/owner_product_service.dart';
import 'widgets/owner_alat_widgets.dart';

class OwnerAlatPage extends StatefulWidget {
  const OwnerAlatPage({super.key, required this.ownerId});

  final dynamic ownerId;

  @override
  State<OwnerAlatPage> createState() => _OwnerAlatPageState();
}

class _OwnerAlatPageState extends State<OwnerAlatPage> {
  final _productService = OwnerProductService();
  final _searchC = TextEditingController();

  bool _loading = true;
  String _searchQuery = '';
  List<Map<String, dynamic>> _products = [];

  static const _green = Color(0xFF297B2D);

  List<Map<String, dynamic>> get _filteredProducts {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _products;

    return _products.where((product) {
      final name = (product['name'] ?? '').toString().toLowerCase();
      final description =
          (product['description'] ?? '').toString().toLowerCase();
      final kapasitas = (product['kapasitas'] ?? '').toString().toLowerCase();
      return name.contains(query) ||
          description.contains(query) ||
          kapasitas.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  @override
  void didUpdateWidget(covariant OwnerAlatPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ownerId != widget.ownerId) _loadProducts();
  }

  @override
  void dispose() {
    _searchC.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (widget.ownerId == null) {
      setState(() => _loading = false);
      return;
    }

    setState(() => _loading = true);
    try {
      final products = await _productService.fetchProducts(widget.ownerId);
      if (!mounted) return;
      setState(() {
        _products = products;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show('Gagal memuat alat: $e');
    }
  }

  Future<void> _openAddProduct() async {
    if (widget.ownerId == null) {
      _show('Data owner belum siap');
      return;
    }

    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerTambahAlatPage(ownerId: widget.ownerId),
      ),
    );

    if (saved == true) _loadProducts();
  }

  Future<void> _openEditProduct(Map<String, dynamic> product) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => OwnerEditAlatPage(
          ownerId: widget.ownerId,
          product: product,
        ),
      ),
    );

    if (saved == true) _loadProducts();
  }

  Future<void> _confirmDeleteProduct(Map<String, dynamic> product) async {
    final deleted = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => OwnerDeleteProductSheet(
        productName: (product['name'] ?? '-').toString(),
        stock: product['stock'] ?? 0,
        price: product['price_per_day'] ?? 0,
        onDelete: () => _productService.deleteProduct(product['id_product']),
      ),
    );

    if (deleted == true) {
      _show('Alat berhasil dihapus');
      _loadProducts();
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchC,
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchC.clear();
                              setState(() => _searchQuery = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 44,
                height: 44,
                child: ElevatedButton(
                  onPressed: _openAddProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _green,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    elevation: 0,
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          if (_loading)
            const Padding(
              padding: EdgeInsets.only(top: 80),
              child: CircularProgressIndicator(color: _green),
            )
          else if (_products.isEmpty)
            const OwnerEmptyProduct()
          else if (_filteredProducts.isEmpty)
            const OwnerNoSearchResult()
          else
            ..._filteredProducts.map((product) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: OwnerToolCard(
                    product: product,
                    onEdit: () => _openEditProduct(product),
                    onDelete: () => _confirmDeleteProduct(product),
                  ),
                )),
        ],
      ),
    );
  }
}
