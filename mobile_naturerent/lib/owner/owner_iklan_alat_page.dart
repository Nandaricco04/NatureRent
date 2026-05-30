import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'services/owner_iklan_service.dart';
import 'widgets/owner_iklan_widgets.dart';

class OwnerIklanAlatPage extends StatefulWidget {
  const OwnerIklanAlatPage({
    super.key,
    required this.userId,
    required this.product,
  });

  final dynamic userId;
  final Map<String, dynamic> product;

  @override
  State<OwnerIklanAlatPage> createState() => _OwnerIklanAlatPageState();
}

class _OwnerIklanAlatPageState extends State<OwnerIklanAlatPage> {
  final _service = OwnerIklanService();
  final _currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp',
    decimalDigits: 0,
  );

  bool _loading = true;
  bool _uploading = false;
  bool _saving = false;
  List<IklanPackage> _packages = [];
  IklanPackage? _selectedPackage;
  String? _proofUrl;

  static const _green = Color(0xFF2E6F33);
  static const _background = Color(0xFFF5F2ED);
  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    try {
      final packages = await _service.fetchPackages();
      if (!mounted) return;
      setState(() {
        _packages = packages;
        _selectedPackage = null;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _show('Gagal memuat paket iklan: $e');
    }
  }

  Future<void> _pickProof() async {
    if (_uploading) return;
    setState(() => _uploading = true);
    try {
      final url = await _service.pickAndUploadProof(userId: widget.userId);
      if (!mounted || url == null) return;
      setState(() => _proofUrl = url);
      _show('Bukti pembayaran berhasil diupload');
    } catch (e) {
      _show('Upload bukti gagal: $e');
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _submit() async {
    final package = _selectedPackage;
    final productId = widget.product['id_product'];

    if (package == null) {
      _show('Pilih paket iklan dulu');
      return;
    }
    if (_proofUrl == null) {
      _show('Upload bukti pembayaran dulu');
      return;
    }
    if (productId == null) {
      _show('Data alat tidak valid');
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.createAdvertisement(
        userId: widget.userId,
        productId: productId,
        package: package,
        proofUrl: _proofUrl!,
      );

      if (!mounted) return;
      _show('Pengajuan iklan menunggu verifikasi');
      Navigator.pop(context, true);
    } catch (e) {
      _show('Gagal membuat iklan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final package = _selectedPackage;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _green))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(30, 26, 30, 36),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    OwnerIklanHeader(onBack: () => Navigator.pop(context)),
                    const SizedBox(height: 24),
                    OwnerIklanProductSummary(product: widget.product),
                    const SizedBox(height: 36),
                    const OwnerIklanSectionTitle(text: 'Pilih Durasi Iklan'),
                    const SizedBox(height: 22),
                    if (_packages.isEmpty)
                      const OwnerIklanEmptyPackages()
                    else
                      Row(
                        children: _packages
                            .map(
                              (item) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                  ),
                                  child: OwnerIklanPackageCard(
                                    package: item,
                                    selected: item.id == package?.id,
                                    currency: _currency,
                                    onTap: () {
                                      setState(() => _selectedPackage = item);
                                    },
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    const SizedBox(height: 46),
                    if (package != null) ...[
                      OwnerIklanPaymentDetail(
                        package: package,
                        currency: _currency,
                      ),
                      const SizedBox(height: 38),
                      const OwnerIklanSectionTitle(text: 'Metode Pembayaran'),
                      const SizedBox(height: 18),
                      const OwnerIklanQrisChip(),
                      const SizedBox(height: 34),
                      OwnerIklanQrisBox(
                        total: package.total,
                        currency: _currency,
                      ),
                      const SizedBox(height: 22),
                      OwnerIklanProofPicker(
                        proofUrl: _proofUrl,
                        uploading: _uploading,
                        onTap: _pickProof,
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _saving ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _green,
                            disabledBackgroundColor: _green.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 4,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'Mulai Iklan Sekarang',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

}
