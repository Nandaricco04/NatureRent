import 'package:flutter/material.dart';

import 'services/user_notification_service.dart';
import 'widgets/user_notification_widgets.dart';

class UserNotificationPage extends StatefulWidget {
  const UserNotificationPage({super.key, required this.userId});

  final dynamic userId;

  @override
  State<UserNotificationPage> createState() => _UserNotificationPageState();
}

class _UserNotificationPageState extends State<UserNotificationPage> {
  final _service = UserNotificationService();

  bool _loading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _service.fetchNotifications(widget.userId);
      await _service.markAllAsRead(widget.userId);

      if (!mounted) return;
      setState(() {
        _notifications = notifications;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Gagal memuat notifikasi';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: userNotificationBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(0xFF297B2D),
          onRefresh: _loadNotifications,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 22, 16, 28),
            children: [
              UserNotificationHeader(onBack: () => Navigator.pop(context)),
              const SizedBox(height: 28),
              if (_loading)
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF297B2D)),
                  ),
                )
              else if (_errorMessage != null)
                _NotificationError(message: _errorMessage!)
              else if (_notifications.isEmpty)
                const UserNotificationEmptyState()
              else
                ..._notifications.map(
                  (notification) =>
                      UserNotificationCard(notification: notification),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationError extends StatelessWidget {
  const _NotificationError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEFEF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.red,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
