import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'services/user_profil_toko_service.dart';
import 'widgets/user_store_card_widget.dart';
import 'widgets/user_product_card_widget.dart';

class UserProfilTokoPage extends StatefulWidget {
  const UserProfilTokoPage({super.key, required this.ownerId});

  final dynamic ownerId;

  @override
  State<UserProfilTokoPage> createState() => _UserProfilTokoPageState();
}

class _UserProfilTokoPageState extends State<UserProfilTokoPage> {
  final _service = UserProfilTokoService();

  bool _loading = true;
  Map<String, dynamic>? _owner;
  List<Map<String, dynamic>> _products = [];
  double _ratingRataRata = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final owner = await _service.fetchOwner(widget.ownerId);
      final products = await _service.fetchProducts(widget.ownerId);
      final rataRata = _service.hitungRataRata(products);

      if (!mounted) return;
      setState(() {
        _owner = owner;
        _products = products;
        _ratingRataRata = rataRata;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memuat profil toko: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF297B2D);
    final topInset = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: primaryGreen,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: primaryGreen),
              )
            : CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          alignment: Alignment.topLeft,
                          height: 190 + topInset,
                          decoration: const BoxDecoration(
                            color: primaryGreen,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(28),
                              bottomRight: Radius.circular(28),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: topInset + 28),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: const Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Profil Toko',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          right: 16,
                          top: topInset + 100,
                          child: _owner == null
                              ? const SizedBox()
                              : UserStoreCardWidget(
                                  owner: _owner!,
                                  ratingRataRata: _ratingRataRata,
                                ),
                        ),
                      ],
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: _owner == null ? 16 : 100),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Text(
                        'Produk',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                    ),
                  ),
                  _products.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Center(
                              child: Text(
                                'Belum ada produk.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          ),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              return UserProductCardWidget(
                                product: _products[index],
                                namaToko: (_owner!['nama_toko'] ?? '')
                                    .toString(),
                              );
                            }, childCount: _products.length),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 0.72,
                                ),
                          ),
                        ),
                ],
              ),
      ),
    );
  }
}
