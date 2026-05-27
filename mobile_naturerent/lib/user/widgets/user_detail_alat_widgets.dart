import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:share_plus/share_plus.dart';

class UserDetailHero extends StatelessWidget {
  const UserDetailHero({
    super.key,
    required this.product,
    required this.onBack,
  });

  final Map<String, dynamic> product;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final imageUrl = (product['image_url'] ?? '').toString();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FullScreenImagePage(imageUrl: imageUrl),
              ),
            );
          },
          child: SizedBox(
            height: 220,
            width: double.infinity,
            child: Hero(
              tag: imageUrl,
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 14,
          left: 14,
          child: _CircleButton(icon: Icons.arrow_back, onTap: onBack),
        ),
        Positioned(
          top: 14,
          right: 14,
          child: _CircleButton(
            icon: Icons.share_outlined,
            onTap: () {
              Share.share(
                'Yuk cek alat outdoor ini!\n\n'
                '${product['name'] ?? ''}\n'
                'Rp${product['price_per_day'] ?? 0} / hari\n\n'
                '$imageUrl',
              );
            },
          ),
        ),
      ],
    );
  }
}

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Hero(
            tag: imageUrl,
            child: PhotoView(
              imageProvider: NetworkImage(imageUrl),
              backgroundDecoration: const BoxDecoration(color: Colors.black),
            ),
          ),
          Positioned(
            top: 40,
            left: 16,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: Colors.black87),
        onPressed: onTap,
      ),
    );
  }
}
