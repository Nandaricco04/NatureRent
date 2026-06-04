import 'package:supabase_flutter/supabase_flutter.dart';

class UserNotificationService {
  UserNotificationService({SupabaseClient? client})
    : _supabase = client ?? Supabase.instance.client;

  final SupabaseClient _supabase;

  Future<List<Map<String, dynamic>>> fetchNotifications(dynamic userId) async {
    await createReturnReminders();

    final data = await _supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data);
  }

  Future<bool> hasUnread(dynamic userId) async {
    await createReturnReminders();

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

  Future<void> markAllAsRead(dynamic userId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }
}
