import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'services/user_detail_alat_service.dart';
import 'user_main_page.dart';
import 'widgets/user_detail_alat_widgets.dart';

class UserDetailAlat extends StatefulWidget {
  final String productId;
  const UserDetailAlat({super.key, required this.productId});

  @override
  State<UserDetailAlat> createState() => _UserDetailAlatState();
}

class _UserDetailAlatState extends State<UserDetailAlat> {
  final _service = UserDetailAlatService();

  Map<String, dynamic>? product;
  List<dynamic> reviews = [];
  int quantity = 1;
  final TextEditingController qtyController = TextEditingController();
  @override
  void dispose() {
    qtyController.dispose();
    super.dispose();
  }

  DateTime startDate = DateTime.now();
  DateTime? endDate;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([_getProduct(), _getReviews()]);
  }

  Future<void> _getProduct() async {
    final data = await _service.fetchProduct(widget.productId);
    if (data != null) setState(() => product = data);
  }

  Future<void> _getReviews() async {
    final data = await _service.fetchReviews(widget.productId);
    setState(() => reviews = data);
  }

  int get totalDays {
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    if (endDate == null) return 0;

    final end = DateTime(endDate!.year, endDate!.month, endDate!.day);

    final days = end.difference(start).inDays;

    return days <= 0 ? 1 : days;
  }

  int get totalPrice {
    if (product == null || endDate == null) return 0;
    return ((product!['price_per_day'] ?? 0) as num).toInt() *
        totalDays *
        quantity;
  }

  String _formatRp(num value) => NumberFormat.currency(
    locale: 'id',
    symbol: 'Rp',
    decimalDigits: 0,
  ).format(value);

  Future<void> _tambahKeKeranjang({bool openCheckout = false}) async {
    try {
      if (product == null) return;

      if (endDate == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pilih tanggal kembali dulu')),
        );
        return;
      }

      final session = await _service.addToCart(
        productIdText: widget.productId,
        product: product!,
        quantity: quantity,
        startDate: startDate,
        endDate: endDate!,
        totalDays: totalDays,
        totalPrice: totalPrice,
      );

      if (!mounted) return;

      if (!openCheckout) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Berhasil masuk keranjang')),
        );
        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => UserMainPage(
            userId: session.userId,
            name: session.name,
            email: session.email,
            initialIndex: 1,
            initialCartId: session.cartId,
            openCartCheckout: openCheckout,
            popCartCheckoutOnBack: true,
          ),
        ),
      );
    } on UserDetailCartException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      debugPrint("ERROR TAMBAH KERANJANG: $e");

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final normalizedStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? startDate : (endDate ?? normalizedStart),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked == null) return;
    setState(() {
      final pickedDate = DateTime(picked.year, picked.month, picked.day);

      if (isStart) {
        startDate = pickedDate;
        if (endDate != null) {
          final normalizedEnd = DateTime(
            endDate!.year,
            endDate!.month,
            endDate!.day,
          );
          if (normalizedEnd.isBefore(startDate)) {
            endDate = null;
          }
        }
      } else {
        if (pickedDate.isBefore(normalizedStart)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Tanggal kembali tidak boleh sebelum tanggal mulai',
              ),
            ),
          );
          return;
        }

        endDate = pickedDate;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xffF7F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [_buildHero(), _buildContent()]),
        ),
      ),
    );
  }

  Widget _buildHero() {
    return UserDetailHero(
      product: product!,
      onBack: () => Navigator.pop(context),
    );
  }

  Widget _buildContent() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategoryAndTitle(),
          const SizedBox(height: 14),
          _buildOwnerCard(),
          const SizedBox(height: 14),
          _buildPriceRow(),
          const Divider(height: 28),
          _buildDescription(),
          const SizedBox(height: 20),
          _buildDateSection(),
          const SizedBox(height: 20),
          _buildQuantityRow(),
          const Divider(height: 28),
          _buildReviews(),
          const SizedBox(height: 20),
          _buildSewaButton(),
        ],
      ),
    );
  }

  Widget _buildCategoryAndTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            product!['categories']['name'] ?? '',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                product!['name'] ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.orange, size: 14),
                  const SizedBox(width: 3),
                  Text(
                    ((product!['rating'] ?? 0) as num).toString(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOwnerCard() {
    final owner = product!['owner'];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14), // lebih kecil dari 16
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xffF6FBF6), Color(0xffEEF7EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20), // sedikit lebih kecil
        border: Border.all(color: Colors.green.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// FOTO TOKO
          Container(
            width: 70, // dari 80 → 70 biar lebih mirip
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.green.shade700,
              image:
                  owner['foto_profil'] != null &&
                      owner['foto_profil'].toString().isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(owner['foto_profil']),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child:
                owner['foto_profil'] == null ||
                    owner['foto_profil'].toString().isEmpty
                ? const Icon(
                    Icons.storefront_rounded,
                    color: Colors.white,
                    size: 26,
                  )
                : null,
          ),

          const SizedBox(width: 12),

          /// INFO TOKO
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  owner['nama_toko'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff1B1B1B),
                  ),
                ),

                const SizedBox(height: 4),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        owner['alamat'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          height: 1.3,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                /// BUTTON
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36, // lebih kecil biar mirip UI
                        child: ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.storefront_outlined,
                            size: 16,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Kunjungi Toko',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade700,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    Container(
                      height: 36,
                      width: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          final alamat = owner['alamat'] ?? '';
                          Clipboard.setData(ClipboardData(text: alamat));

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Alamat berhasil disalin'),
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.copy_rounded,
                          size: 17,
                          color: Colors.green.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _formatRp(product!['price_per_day']),
          style: TextStyle(
            fontSize: 24,
            color: Colors.green.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text('/hari', style: TextStyle(fontSize: 13)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.orange.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "Stok: ${product!['stock']}",
            style: TextStyle(
              color: Colors.orange.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Deskripsi",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product!['description'] ?? '',
          style: const TextStyle(color: Colors.grey, height: 1.6, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF7F6F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Pilih Tanggal Sewa",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateBox("Mulai", startDate, () => _pickDate(true)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDateBox(
                  "Kembali",
                  endDate,
                  () => _pickDate(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              endDate == null ? "Durasi: -" : "Durasi: $totalDays hari",
              style: TextStyle(
                color: Colors.green.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              date == null ? '-' : DateFormat('dd/MM/yyyy').format(date),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: date == null ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityRow() {
    final stock = product!['stock'] ?? 0;

    return Row(
      children: [
        const Text(
          "Jumlah",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const Spacer(),

        _qtyBtn(Icons.remove, () {
          if (quantity > 1) {
            setState(() {
              quantity--;
              qtyController.text = quantity.toString();
            });
          }
        }),

        const SizedBox(width: 10),

        SizedBox(
          width: 55,
          child: TextField(
            controller: qtyController..text = quantity.toString(),
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: const InputDecoration(
              isDense: true,
              border: InputBorder.none,
            ),

            onChanged: (value) {
              final input = int.tryParse(value);

              if (input == null || input < 1) return;

              if (input > stock) {
                setState(() {
                  quantity = stock;
                  qtyController.text = stock.toString();
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Stok hanya tersedia $stock')),
                );
              } else {
                setState(() {
                  quantity = input;
                });
              }
            },
          ),
        ),

        const SizedBox(width: 10),

        _qtyBtn(Icons.add, () {
          if (quantity < stock) {
            setState(() {
              quantity++;
              qtyController.text = quantity.toString();
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Stok hanya tersedia $stock')),
            );
          }
        }),
      ],
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildReviews() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Review",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 14),

        if (reviews.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xffF7F6F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              "Belum ada review.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ),

        ...reviews.map(
          (r) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xffF7F6F2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        r['users']?['nama'] ?? 'User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),

                    Text(
                      _timeAgo(r['created_at']),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: List.generate(
                    ((r['rating'] ?? 0) as num).toInt(),
                    (_) =>
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  r['comment'] ?? '',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _timeAgo(String? date) {
    if (date == null) return '';

    final createdAt = DateTime.parse(date);
    final difference = DateTime.now().difference(createdAt);
    // final TextEditingController qtyController = TextEditingController();

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} minggu lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }

  Widget _buildSewaButton() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF7F6F2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green.shade700, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
            ),
            child: IconButton(
              onPressed: () async {
                await _tambahKeKeranjang();
              },
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.green.shade700,
                size: 28,
              ),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  await _tambahKeKeranjang(openCheckout: true);
                },
                child: Center(
                  child: Text(
                    "Booking Sekarang — ${_formatRp(totalPrice)}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
