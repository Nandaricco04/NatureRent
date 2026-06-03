import 'package:flutter/material.dart';

const userNotificationBackground = Color(0xFFF3F1ED);
const userNotificationOrange = Color(0xFFFF8A00);

class UserNotificationHeader extends StatelessWidget {
  const UserNotificationHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF212121)),
          ),
        ),
        const SizedBox(width: 14),
        const Text(
          'Notifikasi',
          style: TextStyle(
            color: Color(0xFF212121),
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class UserNotificationCard extends StatelessWidget {
  const UserNotificationCard({super.key, required this.notification});

  final Map<String, dynamic> notification;

  @override
  Widget build(BuildContext context) {
    final title = (notification['title'] ?? '').toString();
    final message = (notification['message'] ?? '').toString();
    final type = (notification['type'] ?? '').toString();
    final isRead = notification['is_read'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 9),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: isRead
            ? null
            : Border.all(color: userNotificationOrange.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFD9D9D9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  notificationIcon(type),
                  color: const Color(0xFF212121),
                  size: 24,
                ),
              ),
              if (!isRead)
                Positioned(
                  top: -1,
                  right: -1,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: userNotificationOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.isEmpty ? notificationTitle(type) : title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151515),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF151515),
                    fontSize: 12,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UserNotificationEmptyState extends StatelessWidget {
  const UserNotificationEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'Belum ada notifikasi',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF6D6A66),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class UserNotificationBellButton extends StatelessWidget {
  const UserNotificationBellButton({
    super.key,
    required this.hasUnread,
    required this.onTap,
    this.size = 42,
    this.backgroundColor = const Color(0x2EFFFFFF),
    this.iconColor = Colors.white,
  });

  final bool hasUnread;
  final VoidCallback onTap;
  final double size;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Icon(Icons.notifications_none_rounded, color: iconColor),
              if (hasUnread)
                Positioned(
                  top: 4,
                  right: 5,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: userNotificationOrange,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData notificationIcon(String type) {
  switch (type) {
    case 'booking_success':
      return Icons.check_circle_outline;
    case 'return_reminder':
      return Icons.assignment_return_outlined;
    case 'order_completed':
      return Icons.rate_review_outlined;
    default:
      return Icons.notifications_none_outlined;
  }
}

String notificationTitle(String type) {
  switch (type) {
    case 'booking_success':
      return 'Booking Berhasil';
    case 'return_reminder':
      return 'Pengembalian Alat';
    case 'order_completed':
      return 'Pesanan Selesai';
    default:
      return 'Notifikasi';
  }
}
