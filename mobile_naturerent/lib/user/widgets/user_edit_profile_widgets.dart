import 'package:flutter/material.dart';

class EditProfileHeader extends StatelessWidget {
  const EditProfileHeader({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: const SizedBox(
              width: 38,
              height: 38,
              child: Icon(Icons.arrow_back, color: Color(0xFF212121)),
            ),
          ),
        ),
        const Expanded(
          child: Text(
            'Edit Profil',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF212121),
            ),
          ),
        ),
        const SizedBox(width: 38),
      ],
    );
  }
}

class EditProfileSummary extends StatelessWidget {
  const EditProfileSummary({
    super.key,
    required this.name,
    required this.email,
    required this.uploading,
    this.photoUrl,
  });

  final String name;
  final String email;
  final String? photoUrl;
  final bool uploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Container(
                width: 74,
                height: 74,
                color: const Color(0xFFE9F3EA),
                child: photoUrl == null
                    ? const Icon(
                        Icons.person,
                        color: Color(0xFF297B2D),
                        size: 44,
                      )
                    : Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          return const Icon(
                            Icons.person,
                            color: Color(0xFF297B2D),
                            size: 44,
                          );
                        },
                      ),
              ),
            ),
            if (uploading)
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          email,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6D6A66),
          ),
        ),
      ],
    );
  }
}

class EditProfileFormCard extends StatelessWidget {
  const EditProfileFormCard({
    super.key,
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 18, 14, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 14),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF297B2D),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}
