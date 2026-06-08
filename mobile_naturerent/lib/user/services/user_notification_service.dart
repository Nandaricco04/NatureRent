import 'package:supabase_flutter/supabase_flutter.dart';

class UserNotificationService {
  UserNotificationService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> fetchNotifications(dynamic userId) async {
    await createReturnReminders();
    await createOrderCompletedNotifications(userId);

    final data = await _supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<bool> hasUnread(dynamic userId) async {
    await createReturnReminders();
    await createOrderCompletedNotifications(userId);

    final data = await _supabase
        .from('notifications')
        .select('id_notification')
        .eq('user_id', userId)
        .eq('is_read', false)
        .limit(1);

    return List<Map<String, dynamic>>.from(data).isNotEmpty;
  }

  Future<void> createReturnReminders() async {
    await _supabase.rpc('create_return_reminders');
  }

  Future<void> createOrderCompletedNotifications(dynamic userId) async {
    if (userId == null) return;

    final rows = await _supabase
        .from('transaksi')
        .select('id_transaksi, status_pesanan')
        .eq('user_id', userId);

    final completedRows = List<Map<String, dynamic>>.from(rows).where((row) {
      return _normalizeStatus(row['status_pesanan']) == 'selesai';
    });

    for (final row in completedRows) {
      final transactionId = row['id_transaksi'];
      if (transactionId == null) continue;

      final existing = await _supabase
          .from('notifications')
          .select('id_notification')
          .eq('user_id', userId)
          .eq('transaksi_id', transactionId)
          .eq('type', 'order_completed')
          .limit(1);

      if (List<Map<String, dynamic>>.from(existing).isNotEmpty) continue;

      final transactionCode = _formatTransactionCode(transactionId);
      await _supabase.rpc(
        'create_notification',
        params: {
          'p_user_id': userId,
          'p_transaksi_id': transactionId,
          'p_type': 'order_completed',
          'p_title': 'Pesanan Selesai',
          'p_message':
              'Pesanan $transactionCode sudah selesai. Kamu bisa memberi review untuk alat yang disewa.',
        },
      );
    }
  }

  Future<void> markAllAsRead(dynamic userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  String _normalizeStatus(dynamic value) {
    return (value ?? '').toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s-]+'),
      '_',
    );
  }

  int _readInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse((value ?? '0').toString()) ?? 0;
  }

  String _formatTransactionCode(dynamic id) {
    final number = _readInt(id);
    if (number <= 0) return 'ID0000000';
    return 'ID${number.toString().padLeft(7, '0')}';
  }
}
