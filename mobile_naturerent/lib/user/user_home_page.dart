import 'package:flutter/material.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _EmptyUserPage(
      title: 'Home',
      subtitle: 'Temukan alat outdoor untuk petualanganmu.',
      icon: Icons.home_outlined,
    );
  }
}

class _EmptyUserPage extends StatelessWidget {
  const _EmptyUserPage({
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 52, color: Color(0xFF297B2D)),
              SizedBox(height: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF212121),
                ),
              ),
              SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6D6A66),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
