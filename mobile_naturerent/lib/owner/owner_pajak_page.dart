import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/app_alerts.dart';
import 'services/owner_pajak_service.dart';
import 'widgets/owner_edit_pesanan_widgets.dart';
import 'widgets/owner_pajak_widgets.dart';

class OwnerPajakPage extends StatefulWidget {
  const OwnerPajakPage({super.key, required this.order});

  final Map<String, dynamic> order;

  @override
  State<OwnerPajakPage> createState() => _OwnerPajakPageState();
}

class _OwnerPajakPageState extends State<OwnerPajakPage> {
  final _service = OwnerPajakService();

  String? _proofUrl;
  bool _uploading = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final value = widget.order['bukti_pajak']?.toString();
    if (value != null && value.isNotEmpty) _proofUrl = value;
  }

  Future<void> _pickProof() async {
    if (_uploading) return;

    setState(() => _uploading = true);

    try {
      final proofUrl = await _service.pickAndUploadTaxProof(
        widget.order['id_transaksi'],
      );

      if (!mounted) return;
      setState(() {
        if (proofUrl != null) _proofUrl = proofUrl;
        _uploading = false;
      });

      if (proofUrl != null) _show('Bukti pajak berhasil diupload');
    } catch (e) {
      if (!mounted) return;
      setState(() => _uploading = false);
      _show('Gagal upload bukti pajak: $e');
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    if (_proofUrl == null) {
      _show('Upload bukti pembayaran pajak dulu');
      return;
    }

    setState(() => _saving = true);

    try {
      final updated = await _service.submitTaxProof(
        transactionId: widget.order['id_transaksi'],
        proofUrl: _proofUrl!,
      );

      if (!mounted) return;
      _show('Pajak berhasil dikirim');
      Navigator.pop(context, updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _show('Gagal menyimpan pajak: $e');
    }
  }

  void _show(String message) {
    AppAlerts.showSnackBar(
      context,
      message: _alertTitle(message),
      subtitle: _alertSubtitle(message),
      type: _alertType(message),
    );
  }

  AppAlertType _alertType(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('berhasil')) return AppAlertType.success;
    if (lower.contains('gagal')) return AppAlertType.error;
    return AppAlertType.warning;
  }

  String _alertTitle(String message) {
    if (message == 'Bukti pajak berhasil diupload') {
      return 'Bukti pajak terupload';
    }
    return message;
  }

  String? _alertSubtitle(String message) {
    if (message == 'Bukti pajak berhasil diupload') {
      return 'Bukti siap dikirim untuk pembayaran pajak.';
    }
    if (message == 'Pajak berhasil dikirim') {
      return 'Pembayaran pajak sudah masuk untuk dicek admin.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ownerEditPesananBackground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
          children: [
            OwnerEditPesananHeader(
              title: 'Pajak Admin',
              onBack: () => Navigator.pop(context),
            ),
            const SizedBox(height: 28),
            OwnerEditPesananIdCard(code: _transactionCode),
            const SizedBox(height: 22),
            Text(
              'Pajak yang harus di bayarkan',
              style: GoogleFonts.poppins(
                color: const Color(0xFF111111),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 20),
            OwnerPajakQrCard(amountText: _formatRp(_taxAmount)),
            const SizedBox(height: 28),
            OwnerPajakProofUpload(
              proofUrl: _proofUrl,
              uploading: _uploading,
              onPickProof: _pickProof,
              onPreview: () {
                final url = _proofUrl;
                if (url != null) _showProofPreview(url);
              },
              fileNameFromUrl: _fileNameFromUrl,
            ),
            const SizedBox(height: 34),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _saving || _uploading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ownerEditPesananGreen,
                  disabledBackgroundColor: ownerEditPesananGreen.withValues(
                    alpha: 0.45,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                        'Simpan Perubahan',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF212121),
                  side: const BorderSide(color: Color(0xFF212121)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Batalkan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.all(18),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: InteractiveViewer(
              child: Image.network(
                proofUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24),
                    child: const Text('Bukti pembayaran tidak bisa dimuat'),
                  );
                },
              ),
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

  int get _taxAmount {
    final storedTax = _readInt(widget.order['pajak']);
    if (storedTax > 0) return storedTax;
    final total = _readInt(widget.order['total_harga']);
    final subtotal = _readInt(widget.order['owner_subtotal']);
    final calculated = total - subtotal;
    return calculated > 0 ? calculated : 0;
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  String _formatRp(int value) {
    final text = value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return 'Rp$text';
  }

  String _fileNameFromUrl(String url) {
    final path = Uri.tryParse(url)?.pathSegments.last;
    if (path == null || path.isEmpty) return 'Bukti pajak';
    return Uri.decodeComponent(path);
  }
}
