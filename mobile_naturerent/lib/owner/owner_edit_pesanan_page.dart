import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_alerts.dart';
import 'services/owner_edit_pesanan_service.dart';
import 'widgets/owner_edit_pesanan_widgets.dart';

class OwnerEditPesananPage extends StatefulWidget {
  const OwnerEditPesananPage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<OwnerEditPesananPage> createState() => _OwnerEditPesananPageState();
}

class _OwnerEditPesananPageState extends State<OwnerEditPesananPage> {
  final _service = OwnerEditPesananService();

  late String _status;
  late final String _initialStatus;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _status = (widget.order['status_pesanan'] ?? 'dipesan').toString();
    _initialStatus = _status;
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_isFinishedLocked) {
      _show('Pesanan yang sudah selesai tidak bisa diubah lagi');
      return;
    }

    setState(() => _saving = true);

    try {
      final updated = await _service.updateOrderStatus(
        transactionId: widget.order['id_transaksi'],
        status: _status,
        paymentMethod: _paymentMethod,
      );

      if (!mounted) return;
      _show('Pesanan berhasil diperbarui');
      Navigator.pop(context, {
        'id_transaksi': updated['id_transaksi'],
        'status_pesanan': updated['status_pesanan'],
      });
    } catch (e) {
      _show('Gagal menyimpan pesanan: $e');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _show(String message) {
    AppAlerts.showSnackBar(
      context,
      message: message == 'Pesanan berhasil diperbarui'
          ? 'Pesanan berhasil diperbarui'
          : message,
      subtitle: message == 'Pesanan berhasil diperbarui'
          ? 'Status booking sudah disimpan.'
          : null,
      type: _alertType(message),
    );
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal')) return AppAlertType.error;
    return AppAlertType.warning;
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethod = _paymentMethod;
    final proofUrl = _proofUrl;
    final showProof = paymentMethod.toLowerCase() == 'qris';

    return Scaffold(
      backgroundColor: ownerEditPesananBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            OwnerEditPesananHeader(
              title: 'Edit Pesanan',
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 28),
            OwnerEditPesananIdCard(code: _transactionCode),
            const SizedBox(height: 20),
            OwnerEditPesananInfoCard(
              children: [
                OwnerEditPesananField(
                  label: 'Nama Produk',
                  value: _productNames,
                ),
                const SizedBox(height: 14),
                OwnerEditPesananField(
                  label: 'Harga Sewa',
                  value: _formatRp(
                    widget.order['owner_subtotal'] ??
                        widget.order['total_harga'],
                  ),
                ),
                const SizedBox(height: 14),
                OwnerEditPesananField(
                  label: 'Metode Pembayaran',
                  value: _capitalize(paymentMethod),
                ),
                if (showProof) ...[
                  const SizedBox(height: 14),
                  OwnerEditPesananField(
                    label: 'Bukti Pembayaran',
                    value: proofUrl == null || proofUrl.isEmpty
                        ? 'Belum ada bukti pembayaran'
                        : _fileNameFromUrl(proofUrl),
                    trailing: proofUrl == null
                        ? null
                        : Icons.visibility_outlined,
                    onTap: proofUrl == null
                        ? null
                        : () => _showProofPreview(proofUrl),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 20),
            OwnerEditPesananInfoCard(
              children: [
                const OwnerEditPesananSectionTitle('Tanggal Sewa'),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OwnerEditPesananDateBox(
                        label: 'Mulai',
                        text: _formatDateInput(_startDate),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OwnerEditPesananDateBox(
                        label: 'Selesai',
                        text: _formatDateInput(_endDate),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            OwnerEditPesananStatusCard(
              status: _status,
              locked: _isFinishedLocked,
              onChanged: (value) => setState(() => _status = value),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _saving || _isFinishedLocked ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ownerEditPesananGreen,
                  disabledBackgroundColor: ownerEditPesananGreen.withValues(
                    alpha: 0.45,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isFinishedLocked
                            ? 'Pesanan Sudah Selesai'
                            : 'Simpan Perubahan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF212121),
                  side: const BorderSide(color: Color(0xFF212121)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Batalkan',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showProofPreview(String proofUrl) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              proofUrl,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('Bukti pembayaran tidak bisa dimuat'),
                );
              },
            ),
          ),
        );
      },
    );
  }

  String get _transactionCode {
    final number = _readInt(widget.order['id_transaksi']);
    return 'ID${number.toString().padLeft(7, '0')}';
  }

  String get _productNames {
    final items = widget.order['items'];
    if (items is! List) return 'Alat rental';

    final names = items
        .map((item) {
          if (item is! Map) return null;
          return item['nama_produk']?.toString().trim();
        })
        .where((name) => name != null && name.isNotEmpty)
        .cast<String>()
        .toList();

    if (names.isEmpty) return 'Alat rental';
    return names.join(', ');
  }

  String get _paymentMethod {
    return (widget.order['payment_method'] ?? '-').toString();
  }

  String? get _proofUrl {
    final value = widget.order['bukti_pembayaran']?.toString();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  DateTime? get _startDate => _parseDate(widget.order['tanggal_mulai']);

  DateTime? get _endDate => _parseDate(widget.order['tanggal_kembali']);

  bool get _isFinishedLocked {
    return _normalizeStatus(_initialStatus) == 'selesai';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  String _formatDateInput(DateTime? date) {
    if (date == null) return '-';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  String _formatRp(dynamic value) {
    final number = _readInt(value);
    final text = number.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$text';
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  String _normalizeStatus(String value) {
    return value.trim().toLowerCase().replaceAll(' ', '_');
  }

  String _capitalize(String value) {
    if (value.isEmpty || value == '-') return value;
    return value[0].toUpperCase() + value.substring(1).toLowerCase();
  }

  String _fileNameFromUrl(String url) {
    final path = Uri.tryParse(url)?.pathSegments.last;
    if (path == null || path.isEmpty) return 'Bukti pembayaran';
    return Uri.decodeComponent(path);
  }
}
