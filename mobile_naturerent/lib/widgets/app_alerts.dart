import 'package:flutter/material.dart';

enum AppAlertType { success, warning, error, info }

class AppAlerts {
  static const Color green = Color(0xFF297B2D);
  static const Color deepGreen = Color(0xFF1E5F25);
  static const Color cream = Color(0xFFF7F6F2);
  static const Color text = Color(0xFF212121);
  static const Color muted = Color(0xFF6D6A66);
  static const Color border = Color(0xFFE5E0D8);
  static const Color orange = Color(0xFFE8752A);
  static const Color red = Color(0xFFD32F2F);

  static void showSnackBar(
    BuildContext context, {
    required String message,
    String? subtitle,
    AppAlertType type = AppAlertType.info,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        padding: EdgeInsets.zero,
        content: _AppSnackContent(
          message: message,
          subtitle: subtitle,
          type: type,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }

  static Future<bool> showBookingSuccessSheet(
    BuildContext context, {
    required List<String> transactionCodes,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _BookingSuccessSheet(transactionCodes: transactionCodes);
      },
    );

    return result ?? false;
  }
}

class _AppSnackContent extends StatelessWidget {
  const _AppSnackContent({
    required this.message,
    required this.type,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? subtitle;
  final AppAlertType type;
  final String? actionLabel;
  final VoidCallback? onAction;

  Color get _accent {
    switch (type) {
      case AppAlertType.success:
        return AppAlerts.green;
      case AppAlertType.warning:
        return AppAlerts.orange;
      case AppAlertType.error:
        return AppAlerts.red;
      case AppAlertType.info:
        return const Color(0xFF2F67B2);
    }
  }

  Color get _tint {
    switch (type) {
      case AppAlertType.success:
        return const Color(0xFFEAF6EC);
      case AppAlertType.warning:
        return const Color(0xFFFFF3E8);
      case AppAlertType.error:
        return const Color(0xFFFFEFEF);
      case AppAlertType.info:
        return const Color(0xFFEAF1FF);
    }
  }

  IconData get _icon {
    switch (type) {
      case AppAlertType.success:
        return Icons.check_rounded;
      case AppAlertType.warning:
        return Icons.info_outline_rounded;
      case AppAlertType.error:
        return Icons.close_rounded;
      case AppAlertType.info:
        return Icons.notifications_none_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppAlerts.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: _tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icon, color: _accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppAlerts.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppAlerts.muted,
                      fontSize: 12,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _accent,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                minimumSize: const Size(0, 36),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                actionLabel!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookingSuccessSheet extends StatelessWidget {
  const _BookingSuccessSheet({required this.transactionCodes});

  final List<String> transactionCodes;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final codes = transactionCodes.join(', ');

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD7D2CB),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 22),
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF6EC),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFB8DDBB)),
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: AppAlerts.green,
                    size: 46,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Booking Berhasil',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppAlerts.text,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pesanan kamu sudah dibuat. Cek detail booking untuk melihat status dan informasi penyewaan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppAlerts.muted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppAlerts.cream,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppAlerts.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.receipt_long_outlined,
                          color: AppAlerts.orange,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kode Transaksi',
                              style: TextStyle(
                                color: AppAlerts.muted,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              codes,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppAlerts.text,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context, true),
                    icon: const Icon(Icons.assignment_outlined, size: 20),
                    label: const Text('Lihat Pesanan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppAlerts.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppAlerts.text,
                      side: const BorderSide(color: Color(0xFF212121)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Kembali Belanja',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
